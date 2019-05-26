{ stdenv, fetchgit, perl, icu, zlib, gmp, readline, nqp }:

#  version = "2019.05-25-aec988";
#  src = fetchgit {
#    url = "git://github.com/rakudo/rakudo";
#    rev = "aec988726c881c2d6d02c3b656bfad69abe07994";
#    sha256 = "190skyrj20i4np1kln6dyasxhajb9fdra5m90954xw4jqfnrhjxi";
#  };

stdenv.mkDerivation rec {
  name = "rakudo-${version}";
  version = "2019.05-25-2b1e5a";
  src = fetchgit {
    url = "git://github.com/vrurg/rakudo";
    rev = "2b1e5ab40f650e70dc6cff95f18337da421f304b";
    sha256 = "0mz5py701d8wr65kidkq26piq0rbd26qr9rjpbgfha389l64cmsv";
  };

  patches = [
    files/rakudo-skip-version-check.patch
    files/rakudo-nqp-search-path.patch
  ];

  buildInputs = [ icu zlib gmp readline perl nqp ];
  # propogatedBuildInputs = [ nqp ];
  configureScript = "perl ./Configure.pl";
  configureFlags =
    [ "--backends=moar"
      "--with-nqp=${nqp}/bin/nqp"
      "--no-relocatable"
    ];

  meta = with stdenv.lib; {
    description = "A Perl 6 implementation";
    homepage    = https://www.rakudo.org;
    license     = licenses.artistic2;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ kazcw ];
  };
}

# problems:
# - NQP_HOME is getting set relative to rakudo prefix, in relocatable mode
#   - using no-relocatable doesn't seem to switch it to the STATIC_*_HOME code
#     paths, but it looks like basically the same thing would happen there
# - rakudo tries to install .moarvm modules into nqp path under rakudo prefix,
#   so the modules are in 3 different places (PERL6_HOME, nqp installation,
#   rakudo's nqp modules)
