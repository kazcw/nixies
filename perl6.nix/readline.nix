{ stdenv, rakudo, perl6lib, fetchurl, readline70 }:

let
  instDist = ./tools/install-dist.p6;
in stdenv.mkDerivation rec {
  name = "Readline-${version}";
  version = "0.1.5";
  src = fetchurl {
    url = "mirror://cpan/authors/id/J/JG/JGOFF/Perl6/${name}.tar.gz";
    sha256 = "0kbl0s15whxs30d1nslklqfcq1zl5vj27b7h8892qjdp8h81ivif";
  };
  buildInputs = [ rakudo ] ++ [ readline70 ];
  postPatch = ''
    sed -i \
      -e 's!is native( LIBREADLINE )!is native( "${readline70}/lib/libreadline.so.7" )!' \
      -e 's!cglobal( LIBREADLINE,!cglobal( "${readline70}/lib/libreadline.so.7",!' \
      lib/Readline.pm;
  '';
  buildPhase = ''
    mkdir nix-build0 nix-build1
    HOME=nix-build0 RAKUDO_RERESOLVE_DEPENDENCIES=0 perl6 ${instDist} --for=vendor --to=nix-build1
  '';
  installPhase = "mv nix-build1 $out";
  perl6Module = true;
  requiredPerl6Modules = [];
  meta = with stdenv.lib; {
    homepage = https://github.com/drforr/perl6-readline;
    description = "Perl 6 interface to GNU Readline, the CLI-based line reading library";
    license = licenses.artistic2;
    maintainers = with maintainers; [ kazcw ];
  };
}
