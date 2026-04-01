<!-- SPDX-License-Identifier: Apache-2.0 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [20251119] - 2026-02-27

### Changed
- Updated package version to 20251119.
- Refactored repository structure for nixpkgs-candidate packaging.
- Standardized flake outputs around package name `libvhdi` with compatibility alias `libvhdi-test`.
- Removed the `examples/` directory and refreshed documentation.

### Added
- `update.sh` now checks upstream `YYYYMMDD` tags from `https://github.com/libyal/libvhdi/tags`,
  verifies the release tarball exists, and updates both `version` and `srcHash` in `default.nix`.
- Codeberg release tags published for this line: `20251119` and `latest`.

### Notes
- Repository: https://codeberg.org/NiXOA/libvhdi
- Nixpkgs submission status: Not yet submitted

## [20240509] - 2026-01-10

### Added
- Initial standalone repository structure for nixpkgs submission
- Dual-mode package definition supporting both flake input and traditional fetchurl
- libvhdi package version 20240509 with VHD/VHDX support
- Comprehensive documentation (README, nixpkgs submission guide, development guide)
- Development flake with multiple build variants
- CI/CD workflow for automated testing

### Technical Details
- libvhdi version: 20240509
- Supports VHD and VHDX formats
- Includes vhdiinfo and vhdimount tools
- FUSE2 and FUSE3 support

### Notes
- Synced from NiXOA core v0.5
- Also available in xen-orchestra-ce-nix repository
- Ready for future nixpkgs submission (pending hash update for nixpkgs-test variant)
- Nixpkgs submission status: Not yet submitted

[20251119]: https://codeberg.org/NiXOA/libvhdi/releases/tag/20251119
[20240509]: https://codeberg.org/NiXOA/libvhdi/releases/tag/20240509
