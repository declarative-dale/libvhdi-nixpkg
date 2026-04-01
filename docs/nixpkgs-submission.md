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

1. **Copy file**:
   ```bash
   cp default.nix pkgs/by-name/li/libvhdi/package.nix
   ```

2. **Edit package.nix**:
   - Remove default parameter values (the `? "..."` parts)
   - Update to use actual version and source hash
   - Update maintainers list

   ```nix
   # Current (with defaults):
   { lib, stdenv, fetchurl, autoreconfHook, pkg-config
   , fuse, fuse3, zlib
   , version ? "20251119"
   , srcHash ? "sha256-AmzEHlBr70M5mQkKd3UZo8tHFRDcNS+kTWhnz2oOeZA="
   }:
   stdenv.mkDerivation {
     pname = "libvhdi";
     inherit version;
     src = fetchurl {
       url = "https://github.com/libyal/libvhdi/releases/download/${version}/libvhdi-alpha-${version}.tar.gz";
       hash = srcHash;
     };
     ...
   }

   # For nixpkgs (remove defaults, hardcode values):
   { lib, stdenv, fetchurl, autoreconfHook, pkg-config
   , fuse, fuse3, zlib
   }:
   stdenv.mkDerivation rec {
     pname = "libvhdi";
     version = "20251119";

     src = fetchurl {
       url = "https://github.com/libyal/libvhdi/releases/download/${version}/libvhdi-alpha-${version}.tar.gz";
       hash = "sha256-ACTUAL-HASH-HERE";
     };
     ...
     meta = with lib; {
       ...
       maintainers = with maintainers; [ your-github-username ];
     };
   }
   ```

   **Note**: The package is already in pure nixpkgs form. For nixpkgs submission, remove default parameter values and hardcode the current version/hash.

### Step 4: Add Yourself to Maintainers (if needed)

Edit `maintainers/maintainer-list.nix` - see xen-orchestra-ce-nix nixpkgs-submission.md for details.

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
- Version: 20251119
```

## References

- [Nixpkgs Contributing Guide](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md)
- [pkgs/by-name README](https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/README.md)
