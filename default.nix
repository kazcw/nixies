self: super: {
  moar = super.callPackage ./perl6/moar.nix { };
  nqp = super.callPackage ./perl6/nqp.nix { };
  rakudo = super.callPackage ./perl6/rakudo.nix { };
}
