<!-- SPDX-License-Identifier: Apache-2.0 -->
# Development Guide

## Setup

```bash
git clone https://codeberg.org/NiXOA/libvhdi.git
cd libvhdi
nix develop
```

## Building

### Package Build

```bash
nix build .#libvhdi
./result/bin/vhdiinfo -V
```

### Compatibility Alias Build

```bash
nix build .#libvhdi-test
```

## Updating to New Version

1. **Update package metadata from latest upstream tag**:
   ```bash
   ./update.sh
   ```
   The updater uses Nix's built-in `nix store prefetch-file` to calculate the
   source hash.

2. **Test both outputs**:
   ```bash
   nix build .#libvhdi
   nix build .#libvhdi-test
   ```

## Testing

```bash
nix flake check
nix build .#libvhdi
nix develop .#default -c shellcheck update.sh
./result/bin/vhdiinfo -V
./result/bin/vhdimount -V
```

## Release Process

GitHub Actions runs `.github/workflows/update-check.yml` daily. When a new
upstream libvhdi tag is detected, the workflow updates `default.nix`, builds and
checks the package, commits the change, and pushes a matching repository tag.

Manual release steps:

1. Update CHANGELOG.md
2. Commit changes
3. Tag release:
   ```bash
   VERSION=20251119
   git tag -fa "$VERSION" -m "Release $VERSION"
   git tag -fa latest -m "Latest release $VERSION"
   git push --force origin "$VERSION"
   git push --force origin latest
   ```
