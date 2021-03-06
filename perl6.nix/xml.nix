{ stdenv, rakudo, fetchgit }:

let
  instDist = ./tools/install-dist.p6;
in stdenv.mkDerivation rec {
  name = "XML-${version}";
  version = "0.3.0-ccfe65";
  src = fetchgit {
    url = "git://github.com/supernovus/exemel.git";
    rev = "ccfe655940289b84f012a385403d81561fbc7777";
    sha256 = "1w04kf4h7qibk9n38jwg3yargksqd0i1bwhxaby4drswv9f7kdhx";
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
    description = "A full-featured, pure-perl XML library (parsing, manipulation, emitting, queries, etc.)";
    homepage = https://github.com/supernovus/exemel;
    license = licenses.artistic2;
    maintainers = with maintainers; [ kazcw ];
  };
}
