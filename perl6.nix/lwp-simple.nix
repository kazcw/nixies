{ stdenv, perl6Packages, fetchgit, zef, MIME-Base64, URI, JSON-Tiny }:

let
  modules = [ MIME-Base64 URI ];
  checkModules = [ JSON-Tiny ];
  perl6lib = perl6Packages.makePerl6Path (modules ++ checkModules);
in stdenv.mkDerivation rec {
  name = "LWP-Simple-${version}";
  version = "v0.106-11-g46d3fdb";
  src = fetchgit {
    url = "https://github.com/perl6/perl6-lwp-simple.git";
    rev = "46d3fdb698b5ec0cd819e533abf2e8d235f18765";
    sha256 = "18wzj7m9bhbfdpmpaarfyjgv7q2c4gj81n8ixzhkzi6i4b5s3wfy";
  };
  buildInputs = [ zef ] ++ modules ++ checkModules;
  preInstall = ''mkdir -p $out/home'';
  # skip tests (--/test) because tests require network access
  installPhase = ''HOME=$out/home PERL6LIB='${perl6lib}' zef -to="inst#$out" --/test install .'';
  perl6Module = true;
  requiredPerl6Modules = modules;
  meta = with stdenv.lib; {
    homepage = https://github.com/perl6/perl6-lwp-simple;
    description = "LWP::Simple quick & dirty implementation for Rakudo Perl 6";
    maintainers = with maintainers; [ kazcw ];
  };
}
