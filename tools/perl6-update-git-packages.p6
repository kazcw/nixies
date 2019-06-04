#! /usr/bin/env nix-shell
#! nix-shell -i perl6 -p git -p "dev.rakudo.withPackages(p6: with p6; [JSON-Tiny Nix-Prefetch-Git Git-Repo])"

use v6.d;

use Git::Repo;
use JSON::Tiny;
use Nix::Prefetch::Git;

grammar Fetchgit {
  regex TOP { .* <fetchgit> .* }
  rule fetchgit { src \= fetchgit <set> \; }
  rule set { '{' ~ '}' <attr> * }
  rule attr { <ident> \= [<string> || <bool>] \; }
  token string { \" ~ \" ( <-["]> * ) }
  token bool { 'true' || 'false' } # XXX: should impl actions, make a general <value> type...
  token ident { <[A..Za..z0..9-]> + }
}
class FetchgitActions {
  method TOP($/) { make $<fetchgit>.made; }
  method fetchgit($/) { make $<set>.made; }
  method set($/) { make $<attr>>>.made.flat.hash.item; }
  method attr($/) { make $<ident>.made => $<string>.made; }
  method string($/) { make $0.Str; }
  method ident($/) { make $/; }
}

grammar GitStatus {
  rule TOP { <entry> * }
  token entry { <state> ' ' <path> \n }
  token state { <statch> <statch> }
  token statch { <[\?\ MADRCU]> }
  token path { \N + }
}
class GitStatusActions {
  method TOP($/) { make $<entry>>>.made.flat.hash.item; }
  method entry($/) { make $<path>.made => $<state>.made; }
  method state($/) { make [~] $<statch>; }
  method path($/) { make $/; }
}

sub MAIN {
  given run(<git status -z>, :out) {
    .sink unless .so;
    if (.out.slurp(:close)) {
      die ｢Refusing to modify dirty working tree. Commit your changes, or give me a dedicated worktree.｣;
    }
  }
  Repo.new.pull;

  my $BASE = ｢/var/cache/a｣.IO;
  my %pkgs := Map.new: (
    moar => $BASE.add(｢MoarVM｣),
    nqp => $BASE.add(｢nqp｣),
    rakudo-unwrapped => $BASE.add(｢rakudo｣));

  # in parallel: fetch and apply updates
  my @results = await do for %pkgs.kv -> $name, $path {
    start {
      my $repo = Repo.new(:$path);
      $repo.pull;
      die unless $repo.head.hash;
      die unless $repo.hash;
      update($name, :$repo);
    }
  }
  @results .= grep: {$_};

  # smoke test the new version
  run qww{nix-shell -p "staging.rakudo.withPackages(p6: [p6.JSON-Tiny])" --run true};
  run qww{nix-shell -p "staging.rakudo.withPackages(p6: [p6.Readline])" --run true};

  # commit
  my $n = @results.elems;
  my $desc = @results == 1
    ?? "update " ~ @results.first.summary
    !! ("update " ~ @results».name.join(｢, ｣); ""; |@results».summary).join("\n");
  run <git commit -m>, $desc;
}

class Upgrade {
  has $.name;
  has $.old-ver;
  has $.new-ver;

  method summary(--> Str:D) {
    "{$.name}: {$.old-ver} -> {$.new-ver}"
  }
}

sub update($pkg, :$repo) {
  my $newver = $repo.describe(｢2*｣);
  die unless $newver;
  # read the package and parse the interesting parts
  my $pkgpath = "./perl6.nix/$pkg.nix".IO or die;
  my $data = $pkgpath.slurp;
  my $name = ($data ~~ m:s/name \= \" ~ \" [ ( <-["]>+ ) '-${version}' ]/)[0];
  my $ver = ($data ~~ m:s/version \= \" ~ \" ( <-["]>+ )/)[0];
  my $fgmatch = Fetchgit.parse($data, :actions(FetchgitActions.new));
  die "failed to find fetchgit application in input file $pkg" unless $fgmatch;
  my ($url, $rev, $sha) = $fgmatch.made<url rev sha256>;
  # already up to date?
  return if $rev eq $repo.hash;
  # prefetch from the cache repo into the nix store
  my $newsha = NixGitRepo.new(:url($repo.path), :fetch-submodules).sha256;
  # write the new values
  $data .= subst($sha, $newsha);
  $data .= subst($rev, $repo.hash);
  $data .= subst(qq[version = "$ver"], qq[version = "$newver"]);
  $pkgpath.spurt($data.encode);
  run <git add>, $pkgpath; # protected by git's index lock
  Upgrade.new(:name($pkg), :old-ver($ver), :new-ver($newver))
}
