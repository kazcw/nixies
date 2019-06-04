self: super:
let
  perl6lib = super.callPackage ./perl6lib.nix { };
in
rec {
  moar = super.callPackage ./moar.nix { };
  nqp = super.callPackage ./nqp.nix { inherit moar; };
  rakudo = super.callPackage ./rakudo.nix { inherit nqp perl6lib; };
  zef = super.callPackage ./zef.nix { inherit rakudo; };
  perl6Packages = super.callPackage ./perl6-packages.nix { inherit rakudo; };
}
