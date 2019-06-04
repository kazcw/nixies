{ stdenv, rakudo, perl6lib, fetchgit, File-Which, File-Find }:
let
  instDist = ./tools/install-dist.p6;
  modules = [File-Which File-Find];
  modpath = perl6lib.makePerl6Path modules;
in stdenv.mkDerivation rec {
  name = "Shell-Command-${version}";
  version = "1145ea";
  src = fetchgit {
    url = "git://github.com/tadzik/Shell-Command.git";
    rev = "1145ea0ff71507b2fe932fca6d2a68d4004c7d12";
    sha256 = "003zwb6ngmfmhdinkql0s2nfjhml7w4vmbvxjlm91w5bx8xj7809";
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
    description = "Common shell command replacements";
    maintainers = with maintainers; [ kazcw ];
  };
}

