{ stdenv, fetchgit, perl }:

stdenv.mkDerivation rec {
  name = "moar-${version}";
  version = "2019.05-24-2ccc20";
  src = fetchgit {
    url = "git://github.com/MoarVM/MoarVM";
    rev = "2ccc20fb591ea3b55e41dee7f7fdb5494d0c71be";
    sha256 = "17rrn8qa6jjvcgz07s1gwbs2g1dlvwwiv56j8wfpkfnwa8ak4m3p";
  };

  buildInputs = [ perl ];
  configureScript = "perl ./Configure.pl";

  meta = with stdenv.lib; {
    description = "A VM with adaptive optimization and JIT compilation, built for Rakudo Perl 6";
    homepage    = https://www.moarvm.org;
    license     = licenses.artistic2;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ kazcw ];
  };
}
