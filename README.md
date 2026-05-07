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

Python bindings are disabled for the initial package. Both `fuse` and `fuse3`
remain in `buildInputs` intentionally: downstream users still need FUSE2
compatibility, while the current build detects and links `libfuse3` when it is
available.

## Quick Start

Build the package:

```bash
nix build .#libvhdi -L
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
- `packages.x86_64-linux.libvhdi-test`
- `checks.x86_64-linux.libvhdi-builds`
- `checks.x86_64-linux.libvhdi-test`

The flake also declares `aarch64-linux` outputs. Local checks on non-matching
systems are skipped unless you explicitly ask Nix to evaluate all systems.

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
nix flake check --no-write-lock-file -L
```

The derivation enables upstream `make check` and patches test shebangs before
the check phase. The install check verifies that `libvhdi.so`, `vhdiinfo`, and
`vhdimount` are installed, then runs both tools with `-V`.

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
nix build .#libvhdi -L
nix flake check --no-write-lock-file -L
```

## Update Automation

The GitHub Actions workflow in
[.github/workflows/update-check.yml](.github/workflows/update-check.yml) runs on
a daily schedule and can also be started manually. When it sees a newer upstream
libvhdi `YYYYMMDD` tag, it:

- runs `./update.sh`, which uses Nix's built-in `nix store prefetch-file`
- formats and lints the package files
- builds `.#libvhdi`
- runs `nix flake check --no-write-lock-file -L`
- commits the updated `default.nix`
- creates and pushes a repository tag with the same name as the upstream tag

Manual runs support a `dry_run` option that updates, builds, and checks without
pushing a commit or tag.

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
