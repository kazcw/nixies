{ stdenv, fetchurl, zef }:

stdenv.mkDerivation rec {
  name = "JSON-Tiny-${version}";
  version = "1.0";
  src = fetchurl {
    url = "http://www.cpan.org/authors/id/M/MO/MORITZ/Perl6/JSON-Tiny-1.0.tar.gz";
    sha256 = "16w3mb1ck27k6m0a1f967p2vbzzdnx0vhzn7az4q34rk5p6jp51m";
  };
  buildInputs = [ zef ];
  preInstall = ''mkdir -p $out/home'';
  installPhase = ''HOME=$out/home zef -to="inst#$out" install .'';
  perl6Module = true;
  requiredPerl6Modules = [];
  meta = with stdenv.lib; {
    description = "A minimal JSON (de)serializer";
    homepage = https://github.com/moritz/json;
    license = licenses.artistic2;
    maintainers = with maintainers; [ kazcw ];
  };
}
