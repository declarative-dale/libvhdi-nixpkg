<!-- SPDX-License-Identifier: Apache-2.0 -->
# Development Guide

## Setup

```bash
git clone https://github.com/YOUR-USER/libvhdi-nix.git
cd libvhdi-nix
nix develop
```

## Building

### Development Build (using flake input)

```bash
nix build .#libvhdi
./result/bin/vhdiinfo --version
```

### Nixpkgs-Test Build (using fetchurl)

```bash
# Requires updating hash first
nix build .#libvhdi-nixpkgs-test
```

## Updating to New Version

1. **Check for new releases**:
   ```bash
   curl -s https://api.github.com/repos/libyal/libvhdi/releases/latest | jq -r '.tag_name'
   ```

2. **Update flake.nix**:
   ```nix
   libvhdiSrc = {
     url = "https://github.com/libyal/libvhdi/releases/download/<VERSION>/libvhdi-alpha-<VERSION>.tar.gz";
     flake = false;
   };
   ```

3. **Update flake.lock**:
   ```bash
   nix flake lock --update-input libvhdiSrc
   ```

4. **Get hash for nixpkgs-test**:
   ```bash
   nix-prefetch-url https://github.com/libyal/libvhdi/releases/download/<VERSION>/libvhdi-alpha-<VERSION>.tar.gz
   ```

5. **Update nixpkgs-test variant in flake.nix**

6. **Test both variants**:
   ```bash
   nix build .#libvhdi
   nix build .#libvhdi-nixpkgs-test
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
