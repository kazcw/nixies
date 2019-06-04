{ stdenv, rakudo, perl6lib, fetchgit, LibraryMake, linenoise }:

let
  modules = [ LibraryMake ];
  modpath = perl6lib.makePerl6Path modules;
  instDist = ./tools/install-dist.p6;
in stdenv.mkDerivation rec {
  name = "Linenoise-${version}";
  version = "2017.09.09-480fd9";
  src = fetchgit {
    url = "git://github.com/hoelzro/p6-linenoise.git";
    rev = "480fd919b2c082e691c518fd50c19ad8719532b6";
    sha256 = "0kh9aj1jc8kb7ggvq9s6gk9dg1ifabkxfzy8gr0adv8yk1gk1rq5";
  };
  buildInputs = [ rakudo ] ++ [ linenoise ] ++ modules;
  postPatch = ''
    # TODO
  '';
  buildPhase = ''
    mkdir nix-build0 nix-build1
    HOME=nix-build0 RAKUDO_RERESOLVE_DEPENDENCIES=0 perl6 -I'${modpath}' ${instDist} --for=vendor --to=nix-build1
  '';
  installPhase = "mv nix-build1 $out";
  perl6Module = true;
  requiredPerl6Modules = modules;
  meta = with stdenv.lib; {
    homepage = https://github.com/hoelzro/p6-linenoise;
    description = "Linenoise bindings for Perl 6";
    license = licenses.mit;
    maintainers = with maintainers; [ kazcw ];
  };
}
