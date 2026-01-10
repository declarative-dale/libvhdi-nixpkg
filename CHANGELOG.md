<!-- SPDX-License-Identifier: Apache-2.0 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-01-10

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
- Includes vhdiinfo, vhdimount, and vhdiexport tools
- FUSE2 and FUSE3 support

### Notes
- Synced from NiXOA core v0.5
- Also available in xen-orchestra-ce-nix repository
- Ready for future nixpkgs submission (pending hash update for nixpkgs-test variant)
- Nixpkgs submission status: Not yet submitted

[Unreleased]: https://github.com/YOUR-USER/libvhdi-nix/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/YOUR-USER/libvhdi-nix/releases/tag/v1.0.0
