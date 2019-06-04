{ stdenv, rakudo, perl6lib, fetchgit, MIME-Base64, URI, JSON-Tiny }:

let
  modules = [ MIME-Base64 URI ];
  checkModules = [ JSON-Tiny ];
  modpath = perl6lib.makePerl6Path (modules ++ checkModules);
  instDist = ./tools/install-dist.p6;
in stdenv.mkDerivation rec {
  name = "LWP-Simple-${version}";
  version = "v0.106-11-g46d3fdb";
  src = fetchgit {
    url = "https://github.com/perl6/perl6-lwp-simple.git";
    rev = "46d3fdb698b5ec0cd819e533abf2e8d235f18765";
    sha256 = "18wzj7m9bhbfdpmpaarfyjgv7q2c4gj81n8ixzhkzi6i4b5s3wfy";
  };
  buildInputs = [ rakudo ] ++ modules ++ checkModules;
  buildPhase = ''
    mkdir nix-build0 nix-build1
    HOME=nix-build0 RAKUDO_RERESOLVE_DEPENDENCIES=0 perl6 -I'${modpath}' ${instDist} --for=vendor --to=nix-build1
  '';
  installPhase = "mv nix-build1 $out";
  perl6Module = true;
  requiredPerl6Modules = modules;
  meta = with stdenv.lib; {
    homepage = https://github.com/perl6/perl6-lwp-simple;
    description = "LWP::Simple quick & dirty implementation for Rakudo Perl 6";
    maintainers = with maintainers; [ kazcw ];
  };
}
