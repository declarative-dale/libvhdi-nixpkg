# SPDX-License-Identifier: Apache-2.0
{
  description = "libvhdi - Library and tools to access VHD/VHDX image format";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          libvhdiFuse2 = pkgs.callPackage ./default.nix {
            fuseBackend = "fuse2";
          };
          libvhdiFuse3 = pkgs.callPackage ./default.nix {
            fuseBackend = "fuse3";
          };
        in
        {
          libvhdi = libvhdiFuse3;
          default = libvhdiFuse3;
          libvhdi-fuse2 = libvhdiFuse2;
          libvhdi-fuse3 = libvhdiFuse3;
          # Alias kept for compatibility with previous test naming.
          libvhdi-test = libvhdiFuse3;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            name = "libvhdi-dev";
            packages = with pkgs; [
              nixpkgs-fmt
              nixpkgs-review
              ripgrep
              shellcheck
              git
              jq
            ];
            shellHook = ''
              echo "libvhdi development shell"
              echo "=============================="
              echo ""
              echo "Available packages:"
              echo "  - libvhdi"
              echo "  - libvhdi-fuse2"
              echo "  - libvhdi-fuse3"
              echo "  - libvhdi-test"
              echo ""
              echo "Useful commands:"
              echo "  nix build .#libvhdi"
              echo "  nix build .#libvhdi-fuse2"
              echo "  nix build .#libvhdi-fuse3"
              echo "  nix flake check"
              echo ""
              echo "Update package metadata:"
              echo "  ./update.sh"
            '';
          };
        }
      );

      # Checks for CI
      checks = forAllSystems (system: {
        libvhdi-fuse2 = self.packages.${system}.libvhdi-fuse2;
        libvhdi-fuse3 = self.packages.${system}.libvhdi-fuse3;
      });
    };
}
