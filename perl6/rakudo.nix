{ stdenv, fetchgit, perl, nqp, makeWrapper }:

stdenv.mkDerivation rec {
  name = "rakudo-${version}";
  # To update ${version}:
  # - check out the rev
  # - run: git describe --match "2*"
  version = "2019.03.1-477-ge35c61550";
  src = fetchgit {
    url = "git://github.com/rakudo/rakudo";
    rev = "e35c61550988717a28b191e22608ffd9b04ff953";
    sha256 = "12b9mx6nnjljp9lbm4m8q4505vzszzmifmd8jyar05wp03x67v2r";
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
