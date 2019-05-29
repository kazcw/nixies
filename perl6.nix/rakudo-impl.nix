{ stdenv, perl6Packages , pkgs, makeWrapper, modules ? [] }:

let
  rakudo-unwrapped = pkgs.callPackage ./rakudo-unwrapped.nix { };
  perl6lib = perl6Packages.makePerl6Path modules;
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
