<!-- SPDX-License-Identifier: Apache-2.0 -->
# libvhdi-nix

Standalone Nix packaging for [libvhdi](https://github.com/libyal/libvhdi), the
libyal library and toolset for reading Virtual Hard Disk images.

This repository is kept close to nixpkgs form so `default.nix` can be copied to
`pkgs/by-name/li/libvhdi/package.nix` with minimal changes.

Current upstream release: `20251119`

## What It Provides

- `libvhdi`: shared library for VHD and VHDX access
- `vhdiinfo`: command-line VHD/VHDX metadata inspection tool
- `vhdimount`: FUSE-based VHD/VHDX mounting tool

Python bindings are disabled for the initial package. Upstream libvhdi supports
FUSE2 and FUSE3 as alternative configure-time backends; it does not build one
`vhdimount` binary that links both. This flake exposes both backends as separate
derivations:

- `libvhdi` / `libvhdi-fuse3`: default upstream-preferred FUSE3 build
- `libvhdi-fuse2`: FUSE2 compatibility build

## Quick Start

Build the default FUSE3 package:

```bash
nix build .#libvhdi -L
```

Build a specific FUSE backend:

```bash
nix build .#libvhdi-fuse2 -L
nix build .#libvhdi-fuse3 -L
```

Run the installed tools:

```bash
./result/bin/vhdiinfo -V
./result/bin/vhdimount -V
```

Run the flake checks:

```bash
nix flake check --no-write-lock-file -L
```

## Flake Usage

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    libvhdi.url = "git+https://codeberg.org/NiXOA/libvhdi.git";
  };

  outputs = { nixpkgs, libvhdi, ... }: {
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

## Outputs

- `packages.x86_64-linux.libvhdi`
- `packages.x86_64-linux.default`
- `packages.x86_64-linux.libvhdi-fuse2`
- `packages.x86_64-linux.libvhdi-fuse3`
- `packages.x86_64-linux.libvhdi-test`
- `checks.x86_64-linux.libvhdi-fuse2`
- `checks.x86_64-linux.libvhdi-fuse3`

The flake currently declares only `x86_64-linux` outputs, matching the local and
CI build target for this package repository.

## Development

Enter the development shell:

```bash
nix develop
```

Common checks:

```bash
nix develop .#default -c nixpkgs-fmt --check default.nix flake.nix
nix develop .#default -c shellcheck update.sh
nix build .#libvhdi -L
nix build .#libvhdi-fuse2 -L
nix build .#libvhdi-fuse3 -L
nix flake check --no-write-lock-file -L
```

The derivation enables upstream `make check` and patches test shebangs before
the check phase. The install check verifies that `libvhdi.so`, `vhdiinfo`, and
`vhdimount` are installed, runs both tools with `-V`, and confirms that
`vhdimount` links the selected FUSE backend.

## Updating

Update `default.nix` to the newest upstream `YYYYMMDD` release tag:

```bash
./update.sh
```

The updater:

- reads the current hardcoded `version` from `default.nix`
- finds the latest upstream release tag from `libyal/libvhdi`
- verifies that the release tarball exists
- prefetches the source with `nix store prefetch-file`
- updates the hardcoded `version` and `hash`

After an update, run:

```bash
nix develop .#default -c nixpkgs-fmt default.nix flake.nix
nix build .#libvhdi-fuse2 -L
nix build .#libvhdi-fuse3 -L
nix flake check --no-write-lock-file -L
```

## Update Automation

The GitHub Actions workflow in
[.github/workflows/update-check.yml](.github/workflows/update-check.yml) runs on
a daily schedule and can also be started manually. When it sees a newer upstream
libvhdi `YYYYMMDD` tag, it:

- runs `./update.sh`, which uses Nix's built-in `nix store prefetch-file`
- formats and lints the package files
- builds `.#libvhdi-fuse2` and `.#libvhdi-fuse3`
- runs `nix flake check --no-write-lock-file -L`
- pushes the built variant outputs to Cachix when `CACHIX_CACHE_NAME` and
  `CACHIX_AUTH_TOKEN` are configured
- commits the updated `default.nix`
- creates and pushes a repository tag with the same name as the upstream tag

The workflow configures Cachix with `skipPush: true` before building, then calls
`cachix push` explicitly on the built variant output paths after `nix build`.
This avoids uploading fetched source tarballs or other store paths merely
produced during the build.

The regular CI workflow also has a `tag-release` job, modeled after the
`xo-nixpkg` workflow. On successful pushes to `main`, it verifies that the
packaged `YYYYMMDD` version exists as an upstream libvhdi tag and creates the
same tag in this repository when it is missing.

Manual runs support a `dry_run` option that updates, builds, and checks without
pushing a Cachix path, commit, or tag.

## Nixpkgs Submission

The package is intended for:

```text
pkgs/by-name/li/libvhdi/package.nix
```

See [docs/nixpkgs-submission.md](docs/nixpkgs-submission.md) for the full
submission workflow. In a nixpkgs checkout, copy `default.nix` to the package
path, add or reference the maintainer entry requested by nixpkgs review, and
run:

```bash
nix-build -A libvhdi
nixpkgs-review wip
```

## Repository Layout

```text
.
├── default.nix                 # nixpkgs-style package expression
├── flake.nix                   # package outputs, checks, and dev shell
├── update.sh                   # upstream release/hash updater
├── docs/
│   ├── development.md
│   └── nixpkgs-submission.md
└── README.md
```

## License

This packaging repository is Apache-2.0. See [LICENSE](LICENSE).

Upstream libvhdi is LGPL-3.0-or-later.

## Maintainer

- Dale Morgan, `@declarative-dale`
