# SPDX-License-Identifier: Apache-2.0
# Example: Using libvhdi-nix in a NixOS configuration

{
  description = "Example NixOS configuration using libvhdi-nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    libvhdi-nix.url = "github:YOUR-USER/libvhdi-nix";
  };

  outputs = { self, nixpkgs, libvhdi-nix }: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({config, pkgs, ... }: {
          # Install libvhdi tools
          environment.systemPackages = [
            libvhdi-nix.packages.x86_64-linux.libvhdi
          ];

          # The package provides:
          # - vhdiinfo: Display VHD/VHDX information
          # - vhdimount: Mount VHD/VHDX files via FUSE
          # - vhdiexport: Export VHD to raw format

          # Example usage:
          # $ vhdiinfo /path/to/disk.vhd
          # $ vhdimount /path/to/disk.vhd /mnt/vhd
          # $ vhdiexport /path/to/disk.vhd output.raw
        })
      ];
    };
  };
}
