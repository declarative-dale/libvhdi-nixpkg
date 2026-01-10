# SPDX-License-Identifier: Apache-2.0
{
  description = "libvhdi - Library and tools to access VHD/VHDX image format";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    libvhdiSrc = {
      url = "https://github.com/libyal/libvhdi/releases/download/20240509/libvhdi-alpha-20240509.tar.gz";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, libvhdiSrc }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # Development version using flake input
          # Override src to use pre-fetched flake input instead of fetchurl
          libvhdi = (pkgs.callPackage ./default.nix {
            version = "20240509";
            # Placeholder hash - will be overridden by src below
            srcHash = "sha256-0000000000000000000000000000000000000000000=";
          }).overrideAttrs (old: {
            src = libvhdiSrc;
          });

          default = self.packages.${system}.libvhdi;

          # Test version using fetchurl (as it would work in nixpkgs)
          # This builds exactly as it would in nixpkgs, fetching source itself
          libvhdi-nixpkgs-test = pkgs.callPackage ./default.nix {
            version = "20240509";
            # Note: This hash needs to be obtained via nix-prefetch-url
            srcHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            name = "libvhdi-nix-dev";
            packages = with pkgs; [
              nix-prefetch-url
              nixpkgs-fmt
              nixpkgs-review
              git
              jq
            ];
            shellHook = ''
              echo "libvhdi-nix development shell"
              echo "=============================="
              echo ""
              echo "Available packages:"
              echo "  - libvhdi              (development build with flake input)"
              echo "  - libvhdi-nixpkgs-test (nixpkgs-style build)"
              echo ""
              echo "Useful commands:"
              echo "  nix build .#libvhdi"
              echo "  nix build .#libvhdi-nixpkgs-test"
              echo "  nix flake check"
              echo ""
              echo "Update source hash:"
              echo "  nix-prefetch-url https://github.com/libyal/libvhdi/releases/download/<version>/libvhdi-alpha-<version>.tar.gz"
            '';
          };
        }
      );

      # Checks for CI
      checks = forAllSystems (system: {
        libvhdi-builds = self.packages.${system}.libvhdi;
        # Note: nixpkgs-test variant commented out until hash is updated
        # libvhdi-nixpkgs = self.packages.${system}.libvhdi-nixpkgs-test;
      });
    };
}
