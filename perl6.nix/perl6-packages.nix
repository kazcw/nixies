{ pkgs, stdenv, rakudo }:

rec {
  JSON-Tiny = pkgs.callPackage ./json-tiny.nix { };
  LibraryCheck = pkgs.callPackage ./library-check.nix { };
  Readline = pkgs.callPackage ./readline.nix { LibraryCheck = LibraryCheck; };
}
