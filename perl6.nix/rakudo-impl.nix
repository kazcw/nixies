{ stdenv, perl6lib, pkgs, makeWrapper, nqp, modules ? [] }:

let
  rakudo-unwrapped = pkgs.callPackage ./rakudo-unwrapped.nix { inherit nqp; };
  modpath = perl6lib.makePerl6Path modules;
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
    exec ${rakudo-unwrapped}/bin/perl6 -I "${modpath}" "\$@"
    EOF
    chmod +x perl6
  '';
  installPhase = ''install -Dt $out/bin perl6'';
  propagatedBuildInputs = modules;
}
