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
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          libvhdi = pkgs.callPackage ./default.nix { };
        in
        {
          inherit libvhdi;
          default = libvhdi;
          # Alias kept for compatibility with previous test naming.
          libvhdi-test = libvhdi;
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
              nix-prefetch-scripts
              nixpkgs-fmt
              nixpkgs-review
              git
              jq
            ];
            shellHook = ''
              echo "libvhdi development shell"
              echo "=============================="
              echo ""
              echo "Available packages:"
              echo "  - libvhdi"
              echo "  - libvhdi-test"
              echo ""
              echo "Useful commands:"
              echo "  nix build .#libvhdi"
              echo "  nix build .#libvhdi-test"
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
        libvhdi-builds = self.packages.${system}.libvhdi;
        libvhdi-test = self.packages.${system}.libvhdi-test;
      });
    };
}
