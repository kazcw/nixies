{ stdenv, fetchgit, git, perl, moar }:

stdenv.mkDerivation rec {
  name = "nqp-${version}";
  version = "2019.05.25-0bb659";
  src = fetchgit {
    url = "git://github.com/perl6/nqp";
    rev = "0bb659205474f7e1e7bc3dc6d1859d9552f659f1";
    sha256 = "0w8y3chk35ghfgkvd2i58b334i3mqsz8204ix0xjlqkxhdsxjk80";
  };

  patches = [
    files/nqp-non-relocatable.patch
    files/nqp-moar-revision.patch
  ];

  buildInputs = [ perl moar git ];
  configureScript = "perl ./Configure.pl";
  configureFlags = [
    "--backends=moar"
    "--with-moar=${moar}/bin/moar"
    "--no-relocatable"
  ];

  meta = with stdenv.lib; {
    description = "Not Quite Perl";
    homepage    = https://github.com/perl6/nqp;
    license     = licenses.artistic2;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ kazcw ];
  };
}
