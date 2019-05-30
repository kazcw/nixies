{ pkgs, stdenv, rakudo }:

rec {
  # utilities
  hasPerl6Module = drv: drv?perl6Module;
  requiredPerl6Modules = drvs: let
    mods = pkgs.lib.filter hasPerl6Module drvs;
  in pkgs.lib.unique (mods ++ pkgs.lib.concatLists (pkgs.lib.catAttrs "requiredPerl6Modules" mods));
  makePerl6Path = drvs: stdenv.lib.concatMapStringsSep "," (x: "inst#${x}") (requiredPerl6Modules drvs);

  # modules
  Gumbo = pkgs.callPackage ./gumbo.nix { inherit XML; };
  JSON-Tiny = pkgs.callPackage ./json-tiny.nix { };
  LibraryCheck = pkgs.callPackage ./library-check.nix { };
  LWP-Simple = pkgs.callPackage ./lwp-simple.nix { inherit MIME-Base64 URI JSON-Tiny; };
  MIME-Base64 = pkgs.callPackage ./mime-base64.nix { };
  Nix-Prefetch-Git = pkgs.callPackage ./nix-prefetch-git.nix { inherit JSON-Tiny; };
  Readline = pkgs.callPackage ./readline.nix { };
  URI = pkgs.callPackage ./uri.nix { };
  XML = pkgs.callPackage ./xml.nix { };
}
