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

### FUSE Backend Builds

```bash
nix build .#libvhdi-fuse2
nix build .#libvhdi-fuse3
```

Upstream libvhdi chooses one FUSE backend at configure time. The default
`libvhdi` output uses FUSE3, while `libvhdi-fuse2` keeps a FUSE2 compatibility
build available.

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

2. **Test both FUSE outputs**:
   ```bash
   nix build .#libvhdi-fuse2
   nix build .#libvhdi-fuse3
   ```

## Testing

```bash
nix flake check
nix build .#libvhdi
nix build .#libvhdi-fuse2
nix build .#libvhdi-fuse3
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
