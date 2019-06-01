{ stdenv, rakudo, perl6Packages, fetchgit }:
let
  instDist = ./tools/install-dist.p6;
  modules = [];
  perl6lib = perl6Packages.makePerl6Path modules;
in stdenv.mkDerivation rec {
  name = "File-Find-${version}";
  version = "0.1-41421e";
  src = fetchgit {
    url = "git://github.com/tadzik/File-Find.git";
    rev = "41421e8f1aec7207a1633de17f7630b7ceba1ff3";
    sha256 = "1n7c07qkhb6hygzqjl396k2gg85b6nwnil4sspa902gmni039pgx";
  };
  buildInputs = [ rakudo ] ++ modules;
  buildPhase = ''
    mkdir nix-build0 nix-build1
    HOME=nix-build0 RAKUDO_RERESOLVE_DEPENDENCIES=0 perl6 -I '${perl6lib}' ${instDist} --for=vendor --to=nix-build1
  '';
  installPhase = "mv nix-build1 $out";
  perl6Module = true;
  requiredPerl6Modules = modules;
  meta = with stdenv.lib; {
    description = "File::Find for Perl 6";
    license = licenses.mit;
    maintainers = with maintainers; [ kazcw ];
  };
}

