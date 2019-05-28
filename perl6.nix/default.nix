self: super: {
  moar = super.callPackage ./moar.nix { };
  nqp = super.callPackage ./nqp.nix { };
  rakudo = super.callPackage ./rakudo.nix { };
  zef = super.callPackage ./zef.nix { };
  perl6Packages = super.callPackage ./perl6-packages.nix { };
}
