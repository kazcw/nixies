{ stdenv, rakudo, fetchgit }:

let
  instDist = ./tools/install-dist.p6;
in stdenv.mkDerivation rec {
  name = "MIME-Base64-${version}";
  version = "v1.2.1";
  src = fetchgit {
    url = "git://github.com/perl6/Perl6-MIME-Base64.git";
    rev = version;
    sha256 = "0l67m8mvz3gxml425sd1ggfnhzh4lf754k7w8fngfr453s6lsza1";
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
    description = "Encoding and decoding Base64 ASCII strings";
    homepage = https://github.com/perl6/Perl6-MIME-Base64.git;
    license = licenses.artistic2;
    maintainers = with maintainers; [ kazcw ];
  };
}
