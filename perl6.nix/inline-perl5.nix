{ stdenv, rakudo, perl6Packages, fetchurl, LibraryMake, perl }:
let
  instDist = ./tools/install-dist.p6;
  modules = [];
  buildModules = [LibraryMake];
  buildLib = perl6Packages.makePerl6Path buildModules;
in stdenv.mkDerivation rec {
  name = "Inline-Perl5-${version}";
  version = "0.38";
  src = fetchurl {
    url = "http://www.cpan.org/authors/id/N/NI/NINE/Perl6/Inline-Perl5-0.38.tar.gz";
    sha256 = "076fl0ci6g94i9260da1cjv4f135gx0cwqdxd89276idc3p56p9f";
  };
  buildInputs = [ rakudo ] ++ buildModules;
  propagatedBuildInputs = [ perl ];
  configurePhase = ''
    mkdir nix-build0 nix-build1
    HOME=nix-build0 perl6 -I '${buildLib}' configure.pl6
  '';
  preBuild = ''sed -i 's!PERL6 = .*!PERL6 = ${rakudo}/bin/perl6!' Makefile'';
  postBuild = ''
    echo FIRST BUILD
    HOME=nix-build0 RAKUDO_RERESOLVE_DEPENDENCIES=0 perl6 ${instDist} --for=vendor --to=nix-build1
    mv nix-build1 $out
    rm -r nix-build0; mkdir nix-build0

    echo 2ND BUILD
    sed -i "s!%[?]RESOURCES<libraries/p5helper>!'$out/resources/' ~ %?RESOURCES<libraries/p5helper>.IO.basename!" lib/Inline/Perl5.pm6 lib/Inline/Perl5/Interpreter.pm6
    HOME=nix-build0 RAKUDO_RERESOLVE_DEPENDENCIES=0 perl6 ${instDist} --for=vendor --to=nix-build1
  '';
  installPhase = "rm -r $out; mv nix-build1 $out";
  perl6Module = true;
  requiredPerl6Modules = [];
  meta = with stdenv.lib; {
    description = "Use Perl 5 code in a Perl 6 program";
    license = licenses.artistic2;
    maintainers = with maintainers; [ kazcw ];
  };
}

