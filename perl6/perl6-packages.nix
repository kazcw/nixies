{ pkgs, stdenv, rakudo }:

rec {
  LibraryCheck = pkgs.callPackage ./library-check.nix { };
  Readline = pkgs.callPackage ./readline.nix { LibraryCheck = LibraryCheck; };
}
