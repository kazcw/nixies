{ stdenv, fetchFromGitHub, rakudo, makeWrapper }:

stdenv.mkDerivation rec {
  name = "zef-${version}";
  version = "0.7.4";
  src = fetchFromGitHub {
    owner = "ugexe";
    repo = "zef";
    rev = version;
    sha256 = "054jwdl4v26nfic8yi2jbrb6i5zly2w9bjdag1vk9j1961gdsjpz";
  };

  buildInputs = [ rakudo makeWrapper ];
  installPhase = ''mkdir -p $out; HOME=$TMPDIR perl6 -I. bin/zef -to="inst#$out" install .'';
  postFixup = ''for x in $out/bin/*; do wrapProgram $x --prefix PERL6LIB , "inst#$out"; done'';

  meta = with stdenv.lib; {
    description = "Perl6 Module Management";
    homepage    = https://github.com/ugexe/zef;
    license     = licenses.artistic2;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ kazcw ];
  };
}
