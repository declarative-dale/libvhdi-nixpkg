<!-- SPDX-License-Identifier: Apache-2.0 -->
# Development Guide

## Setup

```bash
git clone https://github.com/YOUR-USER/libvhdi.git
cd libvhdi
nix develop
```

## Building

### Package Build

```bash
nix build .#libvhdi
./result/bin/vhdiinfo --version
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

2. **Test both outputs**:
   ```bash
   nix build .#libvhdi
   nix build .#libvhdi-test
   ```

## Testing

```bash
nix flake check
nix build .#libvhdi
./result/bin/vhdiinfo --version
./result/bin/vhdimount --version
```

## Release Process

1. Update CHANGELOG.md
2. Commit changes
3. Tag release:
   ```bash
   git tag -a v1.0.1 -m "Release v1.0.1"
   git push origin v1.0.1
   ```
