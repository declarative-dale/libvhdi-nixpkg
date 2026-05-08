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
, fuseBackend ? "fuse3"
, zlib
,
}:

let
  validFuseBackends = [
    "fuse2"
    "fuse3"
  ];
  fusePackage =
    if fuseBackend == "fuse2" then
      fuse
    else
      fuse3;
  expectedFuseLibrary =
    if fuseBackend == "fuse2" then
      "libfuse.so"
    else
      "libfuse3.so";
  unexpectedFuseLibrary =
    if fuseBackend == "fuse2" then
      "libfuse3.so"
    else
      "libfuse.so";
in
assert lib.assertMsg (lib.elem fuseBackend validFuseBackends)
  "libvhdi: fuseBackend must be one of: ${lib.concatStringsSep ", " validFuseBackends}";
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
    # Upstream supports FUSE2 and FUSE3 as alternative configure-time backends.
    # Keep one FUSE generation in each derivation so autodetection is explicit.
    fusePackage
    zlib # Compression support
  ];

  configureFlags = [
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

    vhdimount_deps="$(ldd "$out/bin/vhdimount")"
    printf '%s\n' "$vhdimount_deps"
    printf '%s\n' "$vhdimount_deps" | grep -q "${expectedFuseLibrary}"
    if printf '%s\n' "$vhdimount_deps" | grep -q "${unexpectedFuseLibrary}"; then
      echo "vhdimount linked unexpected FUSE backend: ${unexpectedFuseLibrary}" >&2
      exit 1
    fi

    runHook postInstallCheck
  '';

  passthru = {
    inherit fuseBackend;
  };

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
