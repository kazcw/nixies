{ stdenv, rakudo, perl6Packages, fetchgit }:
let
  instDist = ./tools/install-dist.p6;
  modules = [];
  perl6lib = perl6Packages.makePerl6Path modules;
in stdenv.mkDerivation rec {
  name = "Library-Make-${version}";
  version = "1.0.0-7aae51";
  src = fetchgit {
    url = "git://github.com/retupmoca/P6-LibraryMake.git";
    rev = "7aae514f09c18b54e2a5d584df340b70d9776a6d";
    sha256 = "1969ihjavpxiz0vy1sc2pd9hk8dsz00wvy9lz0lpd0rl8y6f7zfb";
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
    description = "An attempt to simplify native compilation";
    license = licenses.mit;
    maintainers = with maintainers; [ kazcw ];
  };
}

