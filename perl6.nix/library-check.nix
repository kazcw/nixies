{ stdenv, rakudo, fetchurl }:

let
  instDist = ./tools/install-dist.p6;
in stdenv.mkDerivation rec {
  name = "LibraryCheck-${version}";
  version = "0.0.8";
  src = fetchurl {
    url = "mirror://cpan/authors/id/J/JS/JSTOWE/Perl6/${name}.tar.gz";
    sha256 = "0k8wrc208dcfn0h7k4rncwj64i2x9zrc1c4dfm7hm700qsdc15fq";
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
    description = "Quick hack to determine whether a shared libray is present";
    homepage = https://github.com/jonathanstowe/LibraryCheck;
    license = licenses.artistic2;
    maintainers = with maintainers; [ kazcw ];
  };
}
