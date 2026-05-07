# SPDX-License-Identifier: Apache-2.0
# libvhdi Package - Library and tools to access Virtual Hard Disk (VHD) image format
# Provides vhdimount (FUSE-based VHD mounter) and vhdiinfo utilities.
#
# This file is structured for nixpkgs submission.
# When submitting to nixpkgs, it will be placed at:
# pkgs/by-name/li/libvhdi/package.nix

{ lib
, stdenv
, fetchurl
, autoreconfHook
, pkg-config
, fuse
, fuse3
, zlib
,
}:

stdenv.mkDerivation rec {
  pname = "libvhdi";
  version = "20251119";

  src = fetchurl {
    url = "https://github.com/libyal/libvhdi/releases/download/${version}/libvhdi-alpha-${version}.tar.gz";
    hash = "sha256-AmzEHlBr70M5mQkKd3UZo8tHFRDcNS+kTWhnz2oOeZA=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    # Keep both FUSE generations: downstream users still need FUSE2 compatibility,
    # while this build detects and links libfuse3 when it is available.
    fuse
    fuse3
    zlib # Compression support
  ];

  configureFlags = [
    "--enable-shared"
    "--enable-static=no"
    "--enable-python=no"
    "--with-libfuse=yes"
    "--enable-multi-threading-support"
    "--enable-wide-character-type"
  ];

  enableParallelBuilding = true;
  doCheck = true;
  doInstallCheck = true;

  preCheck = ''
    patchShebangs tests
  '';

  installCheckPhase = ''
    runHook preInstallCheck

    test -f "$out/lib/libvhdi.so"
    test -f "$out/bin/vhdiinfo"
    test -f "$out/bin/vhdimount"

    "$out/bin/vhdiinfo" -V
    "$out/bin/vhdimount" -V

    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "Library and tools to access the Virtual Hard Disk (VHD) image format";
    longDescription = ''
      libvhdi provides:
      - vhdiinfo: Display information about VHD/VHDX files
      - vhdimount: FUSE-based tool to mount VHD/VHDX as a filesystem

      Used by Xen Orchestra for backup restore and disk inspection operations.
      This package supports both VHD (Virtual Hard Disk) and VHDX (Virtual Hard Disk v2) formats.
    '';
    homepage = "https://github.com/libyal/libvhdi";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = [
      {
        name = "Dale Morgan";
        email = "mail@dalemorgan.us";
        github = "declarative-dale";
      }
    ];
  };
}
