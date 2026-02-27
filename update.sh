#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq gnused

set -euo pipefail

cd "$(dirname "$0")"

latest_version=$(curl -fsSL "https://api.github.com/repos/libyal/libvhdi/tags?per_page=100" | jq -r '
  [ .[]
    | .name
    | select(test("^[0-9]{8}$"))
  ]
  | sort
  | last
')

if [ -z "$latest_version" ] || [ "$latest_version" = "null" ]; then
    echo "Failed to fetch latest version tag" >&2
    exit 1
fi

echo "Latest libvhdi version: $latest_version"

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
