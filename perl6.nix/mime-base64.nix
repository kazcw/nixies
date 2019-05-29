{ stdenv, fetchgit, zef }:

stdenv.mkDerivation rec {
  name = "MIME-Base64-${version}";
  version = "v1.2.1";
  src = fetchgit {
    url = "git://github.com/perl6/Perl6-MIME-Base64.git";
    rev = version;
    sha256 = "0l67m8mvz3gxml425sd1ggfnhzh4lf754k7w8fngfr453s6lsza1";
  };
  buildInputs = [ zef ];
  preInstall = ''mkdir -p $out/home'';
  installPhase = ''HOME=$out/home zef -to="inst#$out" install .'';
  perl6Module = true;
  requiredPerl6Modules = [];
  meta = with stdenv.lib; {
    description = "Encoding and decoding Base64 ASCII strings";
    homepage = https://github.com/perl6/Perl6-MIME-Base64.git;
    license = licenses.artistic2;
    maintainers = with maintainers; [ kazcw ];
  };
}
