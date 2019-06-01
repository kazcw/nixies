{ pkgs, stdenv, rakudo }:

rec {
  # utilities
  hasPerl6Module = drv: drv?perl6Module;
  requiredPerl6Modules = drvs: let
    mods = pkgs.lib.filter hasPerl6Module drvs;
  in pkgs.lib.unique (mods ++ pkgs.lib.concatLists (pkgs.lib.catAttrs "requiredPerl6Modules" mods));
  makePerl6Path = drvs: stdenv.lib.concatMapStringsSep "," (x: "inst#${x}") (requiredPerl6Modules drvs);

  # modules
  File-Find = pkgs.callPackage ./file-find.nix { };
  File-Which = pkgs.callPackage ./file-which.nix { };
  Gumbo = pkgs.callPackage ./gumbo.nix { inherit XML; };
  Inline-Perl5 = pkgs.callPackage ./inline-perl5.nix { inherit LibraryMake; };
  JSON-Tiny = pkgs.callPackage ./json-tiny.nix { };
  LibraryCheck = pkgs.callPackage ./library-check.nix { };
  LibraryMake = pkgs.callPackage ./library-make.nix { };
  LWP-Simple = pkgs.callPackage ./lwp-simple.nix { inherit MIME-Base64 URI JSON-Tiny; };
  MIME-Base64 = pkgs.callPackage ./mime-base64.nix { };
  Nix-Prefetch-Git = pkgs.callPackage ./nix-prefetch-git.nix { inherit JSON-Tiny; };
  NixStoreCUR = pkgs.callPackage ./nix-store-cur.nix { };
  Readline = pkgs.callPackage ./readline.nix { };
  Shell-Command = pkgs.callPackage ./shell-command.nix { inherit File-Which File-Find; };
  URI = pkgs.callPackage ./uri.nix { };
  XML = pkgs.callPackage ./xml.nix { };
}
