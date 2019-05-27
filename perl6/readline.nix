{ stdenv, fetchurl, zef, LibraryCheck, readline70 }:

stdenv.mkDerivation rec {
  name = "Readline-${version}";
  version = "0.1.5";
  src = fetchurl {
    url = "mirror://cpan/authors/id/J/JG/JGOFF/Perl6/${name}.tar.gz";
    sha256 = "0kbl0s15whxs30d1nslklqfcq1zl5vj27b7h8892qjdp8h81ivif";
  };
  buildInputs = [ zef LibraryCheck readline70 ];
  preInstall = ''mkdir -p $out/home'';
  installPhase = ''HOME=$out/home PERL6LIB='inst#${LibraryCheck}' LD_LIBRARY_PATH=${readline70}/lib zef -to="inst#$out" install .'';
  meta = with stdenv.lib; {
    homepage = https://github.com/drforr/perl6-readline;
    description = "Perl 6 interface to GNU Readline, the CLI-based line reading library";
    license = licenses.artistic2;
    maintainers = with maintainers; [ kazcw ];
  };
}
