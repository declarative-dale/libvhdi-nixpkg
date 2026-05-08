<!-- SPDX-License-Identifier: Apache-2.0 -->
# Nixpkgs Submission Guide

This guide outlines the process for submitting the libvhdi package to nixpkgs.

Upstream packaging repository: https://codeberg.org/NiXOA/libvhdi  
Current package release tag: `20251119`

## Prerequisites

1. **Package builds successfully**:
   ```bash
   nix build .#libvhdi
   ```

2. **Source hash is current**:
   ```bash
   ./update.sh
   ```

3. **All tests pass**:
   ```bash
   nix flake check
   nixpkgs-review wip  # In nixpkgs checkout
   ```

## Submission Process

### Step 1: Fork and Clone Nixpkgs

```bash
git clone https://github.com/YOUR-USERNAME/nixpkgs.git
cd nixpkgs
git remote add upstream https://github.com/NixOS/nixpkgs.git
```

### Step 2: Create Package Directory

```bash
mkdir -p pkgs/by-name/li/libvhdi
```

### Step 3: Prepare Package File

Copy the package file:
   ```bash
   cp default.nix pkgs/by-name/li/libvhdi/package.nix
   ```

The repository package is already in nixpkgs form: `stdenv.mkDerivation rec`,
hardcoded `version` and `hash`, and upstream tests enabled. The optional
`fuseBackend` argument defaults to the upstream-preferred FUSE3 build and can be
overridden to `"fuse2"` if nixpkgs review wants a FUSE2 variant.

### Step 4: Add Yourself to Maintainers (if needed)

If the maintainer is not already present in nixpkgs, add the entry to
`maintainers/maintainer-list.nix` and update `meta.maintainers` to reference that
maintainer attribute if requested during review.

### Step 5: Test the Package

```bash
nix-build -A libvhdi
nixpkgs-review wip
```

### Step 6: Create Commit and PR

```bash
git checkout -b add-libvhdi
git add pkgs/by-name/li/libvhdi/
git commit -m "libvhdi: init"
git push origin add-libvhdi
```

## PR Description Template

```markdown
### Description of Changes

Add libvhdi package - Library and tools to access VHD/VHDX image formats.

Provides:
- vhdiinfo: Display VHD/VHDX information
- vhdimount: FUSE-based VHD/VHDX mounter

### Things Done

- [ ] Built on platform(s): x86_64-linux
- [ ] Tested with `nixpkgs-review wip`
- [ ] All tests pass
- [ ] Added myself to maintainers list
- [ ] Followed pkgs/by-name conventions

### Package Details

- Source: GitHub libyal/libvhdi releases
- License: LGPL-3.0-or-later
- Build system: Autotools
- FUSE backend: FUSE3 by default, FUSE2 available through `fuseBackend = "fuse2"`
- Version: 20251119
```

## References

- [Nixpkgs Contributing Guide](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md)
- [pkgs/by-name README](https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/README.md)
