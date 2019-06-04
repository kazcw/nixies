{ stdenv, rakudo, perl6lib, fetchgit }:
let
  instDist = ./tools/install-dist.p6;
  modules = [];
  modpath = perl6lib.makePerl6Path modules;
in stdenv.mkDerivation rec {
  name = "File-Which-${version}";
  version = "1.0.1-1dfbeb";
  src = fetchgit {
    url = "git://github.com/azawawi/perl6-file-which.git";
    rev = "1dfbeba2f92f8b2b04e8b26619eb20d599198d25";
    sha256 = "0i0d33gbscy5v7lbbcsdrfkzmnizrjxjxznzl1qkjna2k4m71r1p";
  };
  buildInputs = [ rakudo ] ++ modules;
  buildPhase = ''
    mkdir nix-build0 nix-build1
    HOME=nix-build0 RAKUDO_RERESOLVE_DEPENDENCIES=0 perl6 -I '${modpath}' ${instDist} --for=vendor --to=nix-build1
  '';
  installPhase = "mv nix-build1 $out";
  perl6Module = true;
  requiredPerl6Modules = modules;
  meta = with stdenv.lib; {
    description = "Cross platform Perl 6 executable path finder (aka which on UNIX)";
    license = licenses.mit;
    maintainers = with maintainers; [ kazcw ];
  };
}

