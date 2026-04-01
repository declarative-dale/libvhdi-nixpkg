<!-- SPDX-License-Identifier: Apache-2.0 -->
# libvhdi

Nix package for [libvhdi](https://github.com/libyal/libvhdi) - Library and tools to access the Virtual Hard Disk (VHD) image format, structured for eventual submission to nixpkgs.

Canonical repository: https://codeberg.org/NiXOA/libvhdi
Current release: `20251119`

## About

libvhdi provides:
- **vhdiinfo**: Display information about VHD/VHDX files
- **vhdimount**: FUSE-based tool to mount VHD/VHDX as a filesystem
- **vhdiexport**: Export VHD data to raw format

This package supports both VHD (Virtual Hard Disk) and VHDX (Virtual Hard Disk v2) formats.

## Usage

### With Flakes

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    libvhdi.url = "git+https://codeberg.org/NiXOA/libvhdi.git";
  };

  outputs = { self, nixpkgs, libvhdi }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          environment.systemPackages = [
            libvhdi.packages.x86_64-linux.libvhdi
          ];
        }
      ];
    };
  };
}
```

### Traditional Nix

```bash
# Clone repository
git clone https://codeberg.org/NiXOA/libvhdi.git
cd libvhdi

# Build package
nix-build -A libvhdi
```

## Development

```bash
# Enter development shell
nix develop

# Build package
nix build .#libvhdi

# Build compatibility test alias
nix build .#libvhdi-test

# Run checks
nix flake check
```

## Nixpkgs Submission

This package is structured for submission to nixpkgs. See [docs/nixpkgs-submission.md](docs/nixpkgs-submission.md) for the detailed submission process.

When submitted to nixpkgs, it will be located at:
- `pkgs/by-name/li/libvhdi/package.nix`

**Current Status:** Not yet submitted

## Updating to New Version

```bash
# Update version + srcHash from latest YYYYMMDD upstream tag
./update.sh

# Test builds
nix build .#libvhdi
nix build .#libvhdi-test
```

## Testing

```bash
# Run all flake checks
nix flake check

# Test libvhdi
nix build .#libvhdi

# Test utilities
./result/bin/vhdiinfo --version
./result/bin/vhdimount --version
./result/bin/vhdiexport --version
```

## Architecture

This repository keeps the **package definition pure** and **flake output minimal**:

- **Package file (`default.nix`)**: Pure nixpkgs-style package that uses `fetchurl`
- **Flake (`flake.nix`)**: Exposes the package on supported systems with a small compatibility alias (`libvhdi-test`)

This approach ensures:
1. `default.nix` is exactly as it'll appear in nixpkgs
2. No flake-specific logic in package definition
3. Updates happen in one place (`default.nix`) via `./update.sh`

## License

Apache-2.0 wrapper - See [LICENSE](LICENSE)

Upstream libvhdi: LGPL-3.0-or-later

## Related Projects

- [NiXOA](https://codeberg.org/NiXOA) - Full NixOS deployment system for Xen Orchestra
- [xen-orchestra-ce-nix](https://codeberg.org/NiXOA/xen-orchestra-ce-nix) - Xen Orchestra CE packaging (which uses libvhdi)
- [libvhdi](https://github.com/libyal/libvhdi) - Upstream library

## Maintainers

- @declarative-dale
