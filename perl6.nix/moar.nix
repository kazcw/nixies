{ stdenv, fetchgit, git, perl }:

stdenv.mkDerivation rec {
  name = "moar-${version}";
  # <AUTOGENERATED> -- see update-perl6-git-package.p6
  version = "2019.05-20-g20930127e";
  src = fetchgit {
    url = "git://github.com/MoarVM/MoarVM";
    rev = "20930127ec691e6fd472245ae3983c76c9088d12";
    sha256 = "1r6cq0y6szl9iq53jrxv8l3n2h2gxnhwa0zqmyy6jpvc0qjxskc2";
    deepClone = true;
  };
  # </AUTOGENERATED>

  buildInputs = [ perl git ];
  configureScript = "perl ./Configure.pl";

  meta = with stdenv.lib; {
    description = "A VM with adaptive optimization and JIT compilation, built for Rakudo Perl 6";
    homepage    = https://www.moarvm.org;
    license     = licenses.artistic2;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ kazcw ];
  };
}
