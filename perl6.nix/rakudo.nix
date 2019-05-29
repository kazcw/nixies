{ stdenv, perl6Packages, pkgs, fetchgit, perl, nqp, makeWrapper, rakudo }:

let
  rakudo = pkgs.callPackage ./rakudo-impl.nix { };
in
  rakudo // {
    withPackages = f: pkgs.callPackage ./rakudo-impl.nix { modules = f perl6Packages; };
  }
