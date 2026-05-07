#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl git gnused nix
# shellcheck shell=bash

set -euo pipefail

cd "$(dirname "$0")"

current_version=$(sed -nE 's/^[[:space:]]*version[[:space:]]*=[[:space:]]*"([0-9]{8})";.*/\1/p' default.nix | head -1)

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
prefetch_output=$(nix store prefetch-file --json --no-pretty --hash-type sha256 "$tarball_url")
new_hash=$(printf '%s\n' "$prefetch_output" | sed -n 's/.*"hash":"\([^"]*\)".*/\1/p' | head -1)

if [ -z "$new_hash" ]; then
    echo "Failed to extract source hash from nix store prefetch-file output" >&2
    echo "$prefetch_output" >&2
    exit 1
fi

echo "New source hash: $new_hash"

sed -i -E "s/(^[[:space:]]*version[[:space:]]*=[[:space:]]*\")[0-9]{8}(\";.*)/\1$latest_version\2/" default.nix
sed -i -E "s|(^[[:space:]]*hash[[:space:]]*=[[:space:]]*\")sha256-[^\"]*(\";.*)|\1$new_hash\2|" default.nix

echo "Updated default.nix:"
echo "  version: $latest_version"
echo "  hash: $new_hash"
