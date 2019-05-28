{ stdenv, pkgs, fetchgit, perl, nqp, makeWrapper, rakudo }:

let
  perl6Packages = pkgs.callPackage ./perl6-packages.nix { };
  rakudo = pkgs.callPackage ./rakudo-impl.nix { };
in
  rakudo // {
    withPackages = f: pkgs.callPackage ./rakudo-impl.nix { modules = f perl6Packages; };
  }
