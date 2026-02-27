#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl git gnused

set -euo pipefail

cd "$(dirname "$0")"

current_version=$(sed -nE 's/^[[:space:]]*version[[:space:]]*\?[[:space:]]*"([0-9]{8})".*/\1/p' default.nix | head -1)

latest_version=$(
  git ls-remote --tags --refs "https://github.com/libyal/libvhdi.git" \
    | sed -nE 's#.*refs/tags/([0-9]{8})$#\1#p' \
    | sort -u \
    | tail -1
)

if [ -z "$latest_version" ] || [ "$latest_version" = "null" ]; then
    echo "Failed to fetch latest version tag from https://github.com/libyal/libvhdi/tags" >&2
    exit 1
fi

if [ -z "$current_version" ]; then
    echo "Failed to read current version from default.nix" >&2
    exit 1
fi

echo "Current libvhdi version: $current_version"
echo "Latest libvhdi version: $latest_version"

if [ "$latest_version" = "$current_version" ]; then
    echo "default.nix is already up to date"
    exit 0
fi

tarball_url="https://github.com/libyal/libvhdi/releases/download/${latest_version}/libvhdi-alpha-${latest_version}.tar.gz"
echo "Checking release tarball: $tarball_url"
if ! curl -fsIL "$tarball_url" >/dev/null; then
    echo "Release tarball not found for tag ${latest_version}" >&2
    exit 1
fi

echo "Prefetching source hash..."
placeholder_hash="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
prefetch_expr=$(cat <<EOF
let
  pkgs = import <nixpkgs> {};
  drv = pkgs.callPackage ./default.nix {
    version = "$latest_version";
    srcHash = "$placeholder_hash";
  };
in
drv.src
EOF
)

set +e
prefetch_output=$(nix-build --no-out-link -E "$prefetch_expr" 2>&1)
prefetch_status=$?
set -e

if [ "$prefetch_status" -eq 0 ]; then
    echo "Unexpectedly resolved src hash with placeholder hash" >&2
    exit 1
fi

new_hash=$(printf '%s\n' "$prefetch_output" | \
    sed -n 's/^[[:space:]]*got:[[:space:]]*\(sha256-[A-Za-z0-9+/=]*\).*/\1/p' | \
    head -1)

if [ -z "$new_hash" ]; then
    echo "Failed to extract src hash from nix-build output" >&2
    echo "$prefetch_output" >&2
    exit 1
fi

echo "New srcHash: $new_hash"

sed -i "s/version ? \"[^\"]*\"/version ? \"$latest_version\"/" default.nix
sed -i "s|srcHash ? \"sha256-[^\"]*\"|srcHash ? \"$new_hash\"|" default.nix

echo "Updated default.nix:"
echo "  version: $latest_version"
echo "  srcHash: $new_hash"
