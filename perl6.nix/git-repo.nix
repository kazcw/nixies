{ stdenv, rakudo, perl6lib }:

let
  instDist = ./tools/install-dist.p6;
  modules = [ ];
  modpath = perl6lib.makePerl6Path modules;
in stdenv.mkDerivation rec {
  name = "Git-Repo";
  version = "0";
  src = ./lib/GitRepo;
  buildInputs = [ rakudo ] ++ modules;
  buildPhase = ''
    mkdir nix-build0 nix-build1
    HOME=nix-build0 RAKUDO_RERESOLVE_DEPENDENCIES=0 perl6 -I "${modpath}" ${instDist} --for=vendor --to=nix-build1
  '';
  installPhase = "mv nix-build1 $out";
  perl6Module = true;
  requiredPerl6Modules = modules;
  meta = with stdenv.lib; {
    description = "yet another git interface";
    homepage = https://github.com/kazcw/nixies;
    license = licenses.artistic2;
    maintainers = with maintainers; [ kazcw ];
  };
}
