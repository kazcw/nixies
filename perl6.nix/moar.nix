{ stdenv, fetchgit, git, perl }:

stdenv.mkDerivation rec {
  name = "moar-${version}";
  # <AUTOGENERATED> -- see update-perl6-git-package.p6
  version = "2019.05-91-g81e5cbf2a";
  src = fetchgit {
    url = "git://github.com/MoarVM/MoarVM";
    rev = "81e5cbf2a9c2c088b930485bba9b8bb80807466a";
    sha256 = "0ywnlh9bxhlrc25br39saw89z1a29hhr564wlyzp16n83i563daf";
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
