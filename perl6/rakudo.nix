{ stdenv, fetchgit, perl, nqp, makeWrapper }:

#  version = "2019.05-25-aec988";
#  src = fetchgit {
#    url = "git://github.com/rakudo/rakudo";
#    rev = "aec988726c881c2d6d02c3b656bfad69abe07994";
#    sha256 = "190skyrj20i4np1kln6dyasxhajb9fdra5m90954xw4jqfnrhjxi";
#  };

stdenv.mkDerivation rec {
  name = "rakudo-${version}";
  # To update ${version}:
  # - check out the rev
  # - run: git describe --match "2*"
  version = "2019.03.1-475-g2b1e5ab40";
  src = fetchgit {
    url = "git://github.com/vrurg/rakudo";
    rev = "2b1e5ab40f650e70dc6cff95f18337da421f304b";
    sha256 = "0mz5py701d8wr65kidkq26piq0rbd26qr9rjpbgfha389l64cmsv";
  };

  buildInputs = [ perl nqp makeWrapper ];
  preConfigure = "echo ${version} > tools/templates/VERSION";
  configureScript = "perl ./Configure.pl";
  configureFlags =
    [ "--backends=moar"
      "--with-nqp=${nqp}/bin/nqp"
      "--no-relocatable"
    ];

  # Workarounds for 2 problems:
  # - rakudo tries to install .moarvm modules into nqp path under rakudo
  #   prefix, so the modules are in 3 different places (PERL6_HOME, nqp
  #   installation, rakudo's nqp modules). The solution here is to move
  #   the misplaced modules into PERL6_HOME.
  # - NQP_HOME is wrong. Fixed here with a wrapper.
  postInstall = "mv $out/share/nqp/lib/Perl6 $out/share/perl6/lib/; wrapProgram $out/bin/perl6 --set NQP_HOME ${nqp}/share/nqp";

  meta = with stdenv.lib; {
    description = "A Perl 6 implementation";
    homepage    = https://www.rakudo.org;
    license     = licenses.artistic2;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ kazcw ];
  };
}
