{ stdenv, fetchurl, zef }:

stdenv.mkDerivation rec {
  name = "LibraryCheck-${version}";
  version = "0.0.8";
  src = fetchurl {
    url = "mirror://cpan/authors/id/J/JS/JSTOWE/Perl6/${name}.tar.gz";
    sha256 = "0k8wrc208dcfn0h7k4rncwj64i2x9zrc1c4dfm7hm700qsdc15fq";
  };
  buildInputs = [ zef ];
  preInstall = ''mkdir -p $out/home'';
  installPhase = ''HOME=$out/home zef -to="inst#$out" install .'';
  meta = with stdenv.lib; {
    description = "Quick hack to determine whether a shared libray is present";
    homepage = https://github.com/jonathanstowe/LibraryCheck;
    license = licenses.artistic2;
    maintainers = with maintainers; [ kazcw ];
  };
}
