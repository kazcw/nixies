{ stdenv, perl6Packages, fetchurl, zef, LibraryCheck, readline70 }:

let
  modules = [ LibraryCheck ];
  perl6lib = perl6Packages.makePerl6Path modules;
in stdenv.mkDerivation rec {
  name = "Readline-${version}";
  version = "0.1.5";
  src = fetchurl {
    url = "mirror://cpan/authors/id/J/JG/JGOFF/Perl6/${name}.tar.gz";
    sha256 = "0kbl0s15whxs30d1nslklqfcq1zl5vj27b7h8892qjdp8h81ivif";
  };
  buildInputs = [ zef ] ++ [ readline70 ] ++ modules;
  postPatch = ''
    sed -i \
      -e 's!is native( LIBREADLINE )!is native( "${readline70}/lib/libreadline.so.7" )!' \
      -e 's!cglobal( LIBREADLINE,!cglobal( "${readline70}/lib/libreadline.so.7",!' \
      lib/Readline.pm;
  '';
  preInstall = ''mkdir -p $out/home'';
  installPhase = ''HOME=$out/home PERL6LIB='${perl6lib}' zef -to="inst#$out" install .'';
  perl6Module = true;
  requiredPerl6Modules = modules;
  meta = with stdenv.lib; {
    homepage = https://github.com/drforr/perl6-readline;
    description = "Perl 6 interface to GNU Readline, the CLI-based line reading library";
    license = licenses.artistic2;
    maintainers = with maintainers; [ kazcw ];
  };
}
