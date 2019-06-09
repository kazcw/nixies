{ stdenv, fetchgit, git, perl, moar }:

stdenv.mkDerivation rec {
  name = "nqp-${version}";
  # <AUTOGENERATED> -- see update-perl6-git-package.p6
  version = "2019.03-222-g23d91629d";
  src = fetchgit {
    url = "git://github.com/perl6/nqp";
    rev = "23d91629d9dca371beac8d16dedc4bba82bd88db";
    sha256 = "1m5lym5bs5bbsr8xv69vla3wphlijx7kkm7inp0bzcf16g98nbhy";
    fetchSubmodules = true;
  };
  # </AUTOGENERATED>

  buildInputs = [ perl moar git ];
  preConfigure = "echo ${version} > VERSION";
  configureScript = "perl ./Configure.pl";
  configureFlags = [
    "--backends=moar"
    "--with-moar=${moar}/bin/moar"
  ];

  meta = with stdenv.lib; {
    description = "Not Quite Perl";
    homepage    = https://github.com/perl6/nqp;
    license     = licenses.artistic2;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ kazcw ];
  };
}
