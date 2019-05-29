{ stdenv, rakudo, fetchgit }:

let
  instDist = ./tools/install-dist.p6;
in stdenv.mkDerivation rec {
  name = "URI-${version}";
  version = "v0.1.3-21-gc5f7d74";
  src = fetchgit {
    url = "git://github.com/perl6-community-modules/uri.git";
    rev = "c5f7d74feacb752e2dcfb07b17006e24fb473063";
    sha256 = "093z03gbvb05za41a4i9ixpscy3das6vwdd5q0xwvy5gndl7fr57";
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
    description = "A URI implementation using Perl 6 grammars to implement RFC 3986 BNF";
    homepage = https://github.com/perl6-community-modules/uri;
    license = licenses.artistic2;
    maintainers = with maintainers; [ kazcw ];
  };
}
