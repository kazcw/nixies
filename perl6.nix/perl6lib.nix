{ pkgs, stdenv }:
rec {
  hasPerl6Module = drv: drv?perl6Module;
  requiredPerl6Modules = drvs: let
    mods = pkgs.lib.filter hasPerl6Module drvs;
  in pkgs.lib.unique (mods ++ pkgs.lib.concatLists (pkgs.lib.catAttrs "requiredPerl6Modules" mods));
  makePerl6Path = drvs: stdenv.lib.concatMapStringsSep "," (x: "inst#${x}") (requiredPerl6Modules drvs);
}
