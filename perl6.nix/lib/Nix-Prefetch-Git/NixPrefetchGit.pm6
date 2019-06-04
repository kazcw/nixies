use v6.d;
use JSON::Tiny;

# nix: patched to absolute path
constant $NIX-PREFETCH-GIT = q<nix-prefetch-git>;

class NixGitRepo is export {
    # how it was fetched
    has Str $.url is rw is required;
    has Str $.rev is required;
    has Str $.sha256 is required;
    # where it fetched to
    # XXX: This store path that is _unrooted_. Anything that accesses files
    # relative to this path is broken if a concurrent nix-store --gc occurs.
    # It's probably better not to expose this at all. The right way to
    # nix-prefetch a git repo and also see its contents is:
    # - clone the repo into a temp directory
    # - observe its files
    # - use nix-prefetch to copy from the temp checkout into the nix store
    # And never touch unrooted paths in the nix store.
    has IO $.path is required is DEPRECATED;

    submethod BUILD(Str() :$url, :$fetch-submodules, :$leave-dotGit, :$deepClone, :$rev, :$hash) is export {
        $!url = $url;
        my @opts = ($NIX-PREFETCH-GIT, '--url', $!url);
        push @opts, '--fetch-submodules' if $fetch-submodules;
        push @opts, '--leave-dotGit' if $leave-dotGit;
        push @opts, '--deepClone' if $deepClone;
        push @opts, '--rev', $rev if $rev.defined;
        push @opts, '--hash', $hash if $hash.defined;
        given run(@opts, :out, :err) {
            .sink unless .so;
            ($!rev, $!sha256) = from-json(.out.slurp(:close))<rev sha256>;
            $!path = (.err.slurp(:close) ~~ m:s<^^path is ("/nix/store/"\N+)$$>)[0].IO;
        }
    }

    method fetch-expr() {
        qq:to/END/.chomp
        \{
            url = "$.url";
            rev = "$.rev";
            sha256 = "$.sha256";
          }
        END
    }
}
