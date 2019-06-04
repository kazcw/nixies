{ perl6lib, pkgs, nqp }:

let
  rakudo = pkgs.callPackage ./rakudo-impl.nix { inherit nqp perl6lib; };
  perl6Packages = pkgs.callPackage ./perl6-packages.nix { inherit rakudo; };
in
  rakudo // {
    withPackages = f: pkgs.callPackage ./rakudo-impl.nix { inherit nqp perl6lib; modules = f perl6Packages; };
  }
