{ stdenv, fetchgit, git, perl, moar }:

stdenv.mkDerivation rec {
  name = "nqp-${version}";
  # <AUTOGENERATED> -- see update-perl6-git-package.p6
  version = "2019.03-198-gd1537d342";
  src = fetchgit {
    url = "git://github.com/perl6/nqp";
    rev = "d1537d3424ce2ff5e1a061fa8773e6cb72611713";
    sha256 = "03ljlff52wfck371jw70ajiivlh547gfjxrppi3647b6s1dm7wb4";
    deepClone = true;
  };
  # </AUTOGENERATED>

  patches = [
    files/nqp-non-relocatable.patch
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