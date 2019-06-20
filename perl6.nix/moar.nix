{ stdenv, fetchgit, git, perl }:

stdenv.mkDerivation rec {
  name = "moar-${version}";
  # <AUTOGENERATED> -- see update-perl6-git-package.p6
  version = "2019.05-87-ga601746d6";
  src = fetchgit {
    url = "git://github.com/MoarVM/MoarVM";
    rev = "a601746d691fdb19b8be889a793274eb62d5f2d9";
    sha256 = "0zb740b6c0z3x9imal7qjdmf7y14p9wnfjkdrkqk2z8hzh5m8nbd";
    fetchSubmodules = true;
  };
  # </AUTOGENERATED>

  buildInputs = [ perl git ];
  preConfigure = "echo ${version} > VERSION";
  configureScript = "perl ./Configure.pl --debug=1";
  dontStrip = true;

  meta = with stdenv.lib; {
    description = "A VM with adaptive optimization and JIT compilation, built for Rakudo Perl 6";
    homepage    = https://www.moarvm.org;
    license     = licenses.artistic2;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ kazcw ];
  };
}
