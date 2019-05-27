{ stdenv, pkgs, makeWrapper, modules ? [] }:

let
  rakudo-unwrapped = pkgs.callPackage ./rakudo-unwrapped.nix { };
  hasPerl6Module = drv: drv?perl6Module;
  requiredPerl6Modules = drvs: let
    mods = pkgs.lib.filter hasPerl6Module drvs;
  in pkgs.lib.unique (mods ++ pkgs.lib.concatLists (pkgs.lib.catAttrs "requiredPerl6Modules" mods));
  makePerl6Path = drvs: stdenv.lib.concatMapStringsSep "," (x: "inst#${x}") (requiredPerl6Modules drvs);
  perl6lib = makePerl6Path modules;
in
stdenv.mkDerivation rec {
  name = "rakudo-${version}";
  inherit (rakudo-unwrapped) version;
  inherit (rakudo-unwrapped) meta;
  src = files/empty;
  buildInputs = [ rakudo-unwrapped ];
  buildPhase = ''
    cat <<EOF > perl6
    #!/bin/sh
    exec ${rakudo-unwrapped}/bin/perl6 -I "${perl6lib}" "\$@"
    EOF
    chmod +x perl6
  '';
  installPhase = ''
    mkdir -p $out/bin
    mv perl6 $out/bin/
  '';
  propagatedBuildInputs = modules;
}
