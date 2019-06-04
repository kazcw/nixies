{ pkgs, rakudo }:
let
  perl6lib = pkgs.callPackage ./perl6lib.nix { };
in
rec {
  File-Find = pkgs.callPackage ./file-find.nix { inherit rakudo; };
  File-Which = pkgs.callPackage ./file-which.nix { inherit rakudo; };
  Git-Repo = pkgs.callPackage ./git-repo.nix { inherit rakudo perl6lib; };
  Gumbo = pkgs.callPackage ./gumbo.nix { inherit rakudo perl6lib XML; };
  Inline-Perl5 = pkgs.callPackage ./inline-perl5.nix { inherit rakudo perl6lib LibraryMake; };
  JSON-Tiny = pkgs.callPackage ./json-tiny.nix { inherit rakudo; };
  LibraryCheck = pkgs.callPackage ./library-check.nix { inherit rakudo; };
  LibraryMake = pkgs.callPackage ./library-make.nix { inherit rakudo; };
  LWP-Simple = pkgs.callPackage ./lwp-simple.nix { inherit rakudo perl6lib MIME-Base64 URI JSON-Tiny; };
  MIME-Base64 = pkgs.callPackage ./mime-base64.nix { inherit rakudo; };
  Nix-Prefetch-Git = pkgs.callPackage ./nix-prefetch-git.nix { inherit rakudo JSON-Tiny perl6lib; };
  NixStoreCUR = pkgs.callPackage ./nix-store-cur.nix { inherit rakudo; };
  Readline = pkgs.callPackage ./readline.nix { inherit rakudo perl6lib; };
  Shell-Command = pkgs.callPackage ./shell-command.nix { inherit rakudo perl6lib File-Which File-Find; };
  URI = pkgs.callPackage ./uri.nix { inherit rakudo; };
  XML = pkgs.callPackage ./xml.nix { inherit rakudo; };
}
