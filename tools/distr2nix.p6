#! /usr/bin/env nix-shell
#! nix-shell -i perl6 -p zef -p git -p "rakudo.withPackages(p6: with p6; [JSON-Tiny Nix-Prefetch-Git LWP-Simple])"

use JSON::Tiny;
use LWP::Simple;
use Nix::Prefetch::Git;

enum Fetcher <fetchurl fetchgit>;

sub map_license($name) {
    return unless $name.defined;
    given lc $name {
        when <mit> { $_ }
        when <artistic-2.0> { <artistic2> }
        default { die "unknown license: $name" }
    }
}

sub map_name(Str:D $name) { $name.subst('::', '-', :g) }

class DistrPkg {
    has Fetcher $.fetcher-name is required;
    has Str $.fetcher is required;
    has Str $.name is required;
    has Str $.version is required;
    has Str $.desc;
    has Str $.license;
    has List $.depends;
    has List $.test-depends;

    method expr() {
        qq:to/END/
        \{ stdenv, rakudo, perl6Packages, {($!fetcher-name, |$!depends).join: ', '} }:
        let
          instDist = ./tools/install-dist.p6;
          modules = [$!depends];
          perl6lib = perl6Packages.makePerl6Path modules;
        in stdenv.mkDerivation rec \{
          name = "$!name-\$\{version}";
          version = "$!version";
          src = $!fetcher-name $!fetcher;
          buildInputs = [ rakudo ] ++ modules;
          buildPhase = ''
            mkdir nix-build0 nix-build1
            HOME=nix-build0 RAKUDO_RERESOLVE_DEPENDENCIES=0 perl6 -I '\$\{perl6lib}' \$\{instDist} --for=vendor --to=nix-build1
          '';
          installPhase = "mv nix-build1 \$out";
          perl6Module = true;
          requiredPerl6Modules = modules;
          meta = with stdenv.lib; \{
            description = "$!desc";{("\n    license = licenses.$_;" with $!license) // ""}
            maintainers = with maintainers; [ kazcw ];
          };
        }
        END
    }
}

grammar Identity {
    token TOP { <path> <adverb> * }
    token path { <ident> + % '::' }
    token adverb { ':' <ident> <value> }
    token value { '<' ~ '>' ( <-[>]> * ) }
    token ident { ( <[a..zA..Z0..9-]> + ) }
}
class CollectAdverbs {
    method TOP($/) { make $<adverb>>>.made.flat.hash.item }
    method adverb($/) { make $<ident>.made => $<value>.made }
    method value($/) { make $0.Str }
    method ident($/) { make $0.Str }
}

sub sauce_from_zef($dist) {
    my $zef-info = do given run(«zef info $dist», :out) {
        .sink unless .so;
        .out.slurp(:close)
    }
    my $sauce;
    for ($zef-info.lines) {
        if /'- Identity: '(.*)/ {
            parse Identity: $0, :actions(CollectAdverbs) or die;
            die unless $/<path> eq $dist;
            my %adv = $/.made;
            # don't actually need any of this?
        }
        $sauce = $0 if m/<[Ss]>'ource-url:'<.ws>(.*)/;
    }
    $sauce.Str
}

sub MAIN(
    Str $dist!, #= Distribution to generate a package for
    Str :from($sauce) = sauce_from_zef $dist #= URL for distribution's source
) {
    my ($fetcher-name, $fetcher, $meta, $ver-override) = do given $sauce {
        when /^git\:/ { fetch_git($sauce) }
        when /^http/ { fetch_http($sauce) }
        default { die "I can't fetch this: '$sauce'" }
    }
    my $d = DistrPkg.new:
        :fetcher-name($fetcher-name)
        :fetcher($fetcher)
        :desc($meta<description>)
        :license(map_license $meta<license>)
        :name(map_name $meta<name>)
        :version($ver-override // $meta<version>)
        :depends(@(map $meta<depends>//(): &map_name))
        :test-depends(@(map $meta<test-depends>//(): &map_name));
    say $d.expr;
}

class Repo {
    has Str $.url is required;
    has IO $.path is required;
    submethod BUILD(:$!url) {
        $!path = new_tmppath;
        $!path.mkdir;
        run «git clone --bare --single-branch -q "$!url" "$!path"»;
    }

    method rev() {
        # in a fresh bare checkout, HEAD will be the only packed ref
        $!path.add('packed-refs').lines.grep(/.* 'refs/'/).split(' ')[0];
    }

    method read(Str() $path) {
        given run «git show "HEAD:$path"», :cwd($!path), :out {
            .sink unless .so;
            .out.slurp(:close)
        }
    }

    method describe(*@globs) {
        my @cmd = |<git describe --tags>, |(<--matches>, $_ for @globs);
        .out.slurp(:close).chomp when run @cmd, :cwd($!path), :out, :!err;
    }

    # Wipes the repo off the face of the disk. Don't try to do anything else with this object afterward!
    method nuke() {
        run «rm -rf "$!path"»;
    }
}

sub fetch_git(Str() $url) {
    # Source is a git head, so "version" in the META is imprecise;
    # let's augment it so it uniquely identifies the source.

    # check it out somewhere safe from nix GC
    my $dir will { .nuke };
    $dir = Repo.new(:$url);

    my $meta = from-json $dir.read('META6.json');
    my $base-ver = $meta<version>;
    # (if base-ver is '*', this glob will accept any tag)
    my $ver = $dir.describe("$base-ver*", "v$base-ver*")
        // ($base-ver~'-' if $base-ver ne '*') ~ $dir.rev.substr(0, 6);

    # "Prefetch" from the full repo
    my $repo = NixGitRepo.new(:url($dir.path));
    $repo.url = $url;

    (fetchgit, $repo.fetch-expr, $meta, $ver)
}

sub new_tmppath() {
    my $id = (|('a'..'z'), |('A'..'Z'), |('0'..'9')).roll(6).join;
    "/tmp".IO.add("sixnix.$id");
}

sub fetch_http(Str() $url) {
    # download the file outside the nix store so we can look at it without daemons eating it
    # (have to use a temp file because: nix-prefetch-url spurns its stdin, and Proc doesn't support opening with additional fds)
    my $file will leave { .unlink };
    $file = new_tmppath;
    $file.spurt: LWP::Simple.get($url);
    my $name = ($url ~~ m'\/(<-[/]>*)$')[0].Str;
    my $sha = do given run(«nix-prefetch-url --name "$name" "file://$file"», :out, :!err) {
        .sink unless .so;
        .out.slurp(:close).chomp
    }
    my $meta = from-json do given run(«tar -z -x -f $file -O --wildcards */META6.json», :out) {
        .sink unless .so;
        .out.slurp(:close)
    }

    my $fetch = qq:to/END/.chomp;
    \{
        url = "$url";
        sha256 = "$sha";
      }
    END
    (fetchurl, $fetch, $meta)
}
