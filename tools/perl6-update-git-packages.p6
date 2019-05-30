#! /usr/bin/env nix-shell
#! nix-shell -i perl6 -p git -p "rakudo.withPackages(p6: with p6; [JSON-Tiny Nix-Prefetch-Git])"

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
  my @pkgs := <moar nqp rakudo-unwrapped>;

  # to test in context
  # we modify in situ
  # in a clean repo
  my $git = run(<git status -u --porcelain=v1 --no-renames>, :out);
  my $status = $git.out.slurp: :close;
  my $statusmatch = GitStatus.parse($status, :actions(GitStatusActions.new));
  die "failed to parse git output" unless $statusmatch;
  for $statusmatch.made.kv -> $path, $st {
    die "refusing to modify working tree: file '$path' in state [$st]";
  }
  my @results = await do for @pkgs { start { update($_) } };
  @results .= grep: {$_};

  # smoke test the new version
  die unless run qww{nix-shell -p "rakudo.withPackages(p6: [p6.JSON-Tiny])" --run true};
  die unless run qww{nix-shell -p "rakudo.withPackages(p6: [p6.Readline])" --run true};

  # commit
  my $n = @results.elems;
  my $desc = ("update $n package" ~ ($n > 1 ?? "s" !! ""), "", |@results).join("\n");
  run «git commit -m "$desc"»;
}

sub update($pkg) {
  my $pkgpath = "./perl6.nix/$pkg.nix".IO or die;
  # read the input file and parse the fetchgit application
  my $data = $pkgpath.slurp;
  my $fgmatch = Fetchgit.parse($data, :actions(FetchgitActions.new));
  die "failed to find fetchgit application in input file $pkg" unless $fgmatch;
  my ($url, $rev, $sha) = $fgmatch.made<url rev sha256>;

  # fetch the repo
  my $repo = NixGitRepo::new: :url($url) :fetch-submodules :leave-dotGit :deepClone;
  my ($newrev, $newsha, $newrepo) = ($repo.rev, $repo.sha256, $repo.path);

  # so is there an update?
  return if $newsha eq $sha;
  die if $rev eq $newrev;

  # git-describe to get version
  my $git-describe = run(<git describe --tags --match 2*>, :cwd($newrepo), :out) or die;
  my $newver = ($git-describe.out.slurp: :close).chomp;

  # describe the change
  my $name = ($data ~~ m:s/name \= \" ~ \" [ ( <-["]>+ ) '-${version}' ]/)[0];
  my $ver = ($data ~~ m:s/version \= \" ~ \" ( <-["]>+ )/)[0];

  # write the new values
  $data .= subst($sha, $newsha);
  $data .= subst($rev, $newrev);
  $data .= subst(qq[version = "$ver"], qq[version = "$newver"]);
  $pkgpath.spurt($data.encode);
  run «git add "$pkgpath"»;
  "$name: $ver -> $newver"
}
