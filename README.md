<!-- SPDX-License-Identifier: Apache-2.0 -->
# libvhdi-nix

Nix package for [libvhdi](https://github.com/libyal/libvhdi) - Library and tools to access the Virtual Hard Disk (VHD) image format, structured for eventual submission to nixpkgs.

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
    libvhdi-nix.url = "github:YOUR-USER/libvhdi-nix";
  };

  outputs = { self, nixpkgs, libvhdi-nix }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          environment.systemPackages = [
            libvhdi-nix.packages.x86_64-linux.libvhdi
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
git clone https://github.com/YOUR-USER/libvhdi-nix.git
cd libvhdi-nix

# Build package
nix-build -A libvhdi
```

## Development

```bash
# Enter development shell
nix develop

# Build package with flake input (development mode)
nix build .#libvhdi

# Build package with fetchurl (nixpkgs-style, submission test mode)
# Note: Requires updating source hash first
nix build .#libvhdi-nixpkgs-test

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
# Check for new releases
curl -s https://api.github.com/repos/libyal/libvhdi/releases/latest | jq -r '.tag_name'

# Update flake.nix libvhdiSrc input with new version
# Then update flake.lock
nix flake lock --update-input libvhdiSrc

# Get hash for nixpkgs-test build
nix-prefetch-url https://github.com/libyal/libvhdi/releases/download/<version>/libvhdi-alpha-<version>.tar.gz

# Update srcHash in flake.nix for nixpkgs-test variant

# Test both build variants
nix build .#libvhdi
nix build .#libvhdi-nixpkgs-test
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

This repository keeps the **package definition pure** while the **flake handles development flexibility**:

- **Package file (`default.nix`)**: Pure nixpkgs-style package that uses `fetchurl`
- **Flake (`flake.nix`)**: Handles both modes by overriding `src` for development builds

**Development mode** (in `flake.nix`):
- Calls package with placeholder parameters
- Overrides `src` with pre-fetched flake input
- Fast iteration, no re-fetching

**Nixpkgs-test mode** (in `flake.nix`):
- Calls package with actual version/hash parameters
- Package fetches source itself (just like in nixpkgs)
- Tests exact submission behavior

This approach ensures:
1. `default.nix` is exactly as it'll appear in nixpkgs
2. No flake-specific logic in package definition
3. Flake provides development ergonomics without polluting the package

## License

Apache-2.0 wrapper - See [LICENSE](LICENSE)

Upstream libvhdi: LGPL-3.0-or-later

## Related Projects

- [NiXOA](https://codeberg.org/NiXOA) - Full NixOS deployment system for Xen Orchestra
- [xen-orchestra-ce-nix](https://github.com/YOUR-USER/xen-orchestra-ce-nix) - Xen Orchestra CE package (which uses libvhdi)
- [libvhdi](https://github.com/libyal/libvhdi) - Upstream library

## Maintainers

- Your Name (@your-github-username)
