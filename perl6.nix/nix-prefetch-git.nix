{ stdenv, rakudo, perl6lib, nix-prefetch-git, JSON-Tiny }:

let
  instDist = ./tools/install-dist.p6;
  modules = [ JSON-Tiny ];
  modpath = perl6lib.makePerl6Path modules;
in stdenv.mkDerivation rec {
  name = "Nix-Prefetch-Git";
  version = "0";
  src = ./lib/Nix-Prefetch-Git;
  buildInputs = [ rakudo ] ++ [ nix-prefetch-git ] ++ modules;
  postPatch = "sed -i 's!constant $NIX-PREFETCH-GIT = q<nix-prefetch-git>;!constant $NIX-PREFETCH-GIT = q<${nix-prefetch-git}/bin/nix-prefetch-git>;!' NixPrefetchGit.pm6";
  buildPhase = ''
    mkdir nix-build0 nix-build1
    HOME=nix-build0 RAKUDO_RERESOLVE_DEPENDENCIES=0 perl6 -I "${modpath}" ${instDist} --for=vendor --to=nix-build1
  '';
  installPhase = "mv nix-build1 $out";
  perl6Module = true;
  requiredPerl6Modules = modules;
  meta = with stdenv.lib; {
    description = "nix-prefetch-git wrapper";
    homepage = https://github.com/kazcw/nixies;
    license = licenses.artistic2;
    maintainers = with maintainers; [ kazcw ];
  };
}
