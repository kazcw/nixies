self: super: {
  moar = super.callPackage ./perl6/moar.nix { };
  nqp = super.callPackage ./perl6/nqp.nix { };
  rakudo = super.callPackage ./perl6/rakudo.nix { };
  zef = super.callPackage ./perl6/zef.nix { };
  perl6Packages = rec {
    LibraryCheck = super.callPackage ./perl6/library-check.nix { };
    Readline = super.callPackage ./perl6/readline.nix { LibraryCheck = LibraryCheck; };
  };
}
