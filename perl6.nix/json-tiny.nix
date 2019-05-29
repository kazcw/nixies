{ stdenv, rakudo, fetchurl }:

let
  instDist = ./tools/install-dist.p6;
in stdenv.mkDerivation rec {
  name = "JSON-Tiny-${version}";
  version = "1.0";
  src = fetchurl {
    url = "http://www.cpan.org/authors/id/M/MO/MORITZ/Perl6/JSON-Tiny-1.0.tar.gz";
    sha256 = "16w3mb1ck27k6m0a1f967p2vbzzdnx0vhzn7az4q34rk5p6jp51m";
  };
  buildInputs = [ rakudo ];
  buildPhase = ''
    mkdir nix-build0 nix-build1
    HOME=nix-build0 RAKUDO_RERESOLVE_DEPENDENCIES=0 perl6 ${instDist} --for=vendor --to=nix-build1
  '';
  installPhase = "mv nix-build1 $out";
  perl6Module = true;
  requiredPerl6Modules = [];
  meta = with stdenv.lib; {
    description = "A minimal JSON (de)serializer";
    homepage = https://github.com/moritz/json;
    license = licenses.artistic2;
    maintainers = with maintainers; [ kazcw ];
  };
}
