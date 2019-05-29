{ stdenv, perl6Packages, fetchgit, zef, gumbo, XML }:

let
  modules = [ XML ];
  perl6lib = perl6Packages.makePerl6Path modules;
in stdenv.mkDerivation rec {
  name = "Gumbo-${version}";
  version = "2019.05.10-3ee54a";
  src = fetchgit {
    url = "git://github.com/Skarsnik/perl6-gumbo.git";
    rev = "3ee54af61ca1e45a967c520d815936739bf903ae";
    sha256 = "0zcyy7pf4y4kkdwgscyh3v7m9pa6cwz3z6jhcx78mdycjy928f4r";
  };
  buildInputs = [ zef ] ++ [ gumbo ] ++ modules;
  prePatch = ''sed -i 's:&GenMyLibName:"${gumbo}/lib/libgumbo.so.1":' lib/Gumbo/Binding.pm6'';
  preInstall = ''mkdir -p $out/home'';
  installPhase = ''HOME=$out/home PERL6LIB='${perl6lib}' zef -to="inst#$out" install .'';
  perl6Module = true;
  requiredPerl6Modules = modules;
  meta = with stdenv.lib; {
    homepage = https://github.com/Skarsnik/perl6-gumbo;
    description = "Perl6 binding to the Gumbo HTML5 parsing library.";
    license = licenses.artistic2;
    maintainers = with maintainers; [ kazcw ];
  };
}
