self: super: {
  moar = super.callPackage ./perl6/moar.nix { };
  nqp = super.callPackage ./perl6/nqp.nix { };
  rakudo = super.callPackage ./perl6/rakudo.nix { };
  zef = super.callPackage ./perl6/zef.nix { };
  perl6Packages = super.callPackage ./perl6/perl6-packages.nix { };
}
