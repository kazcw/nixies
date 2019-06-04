use v6.d;
use JSON::Tiny;

# nix: patched to absolute path
constant $NIX-PREFETCH-GIT = q<nix-prefetch-git>;

class NixGitRepo is export {
    has Str $.url is rw is required;
    has Str $.rev is required;
    has Str $.sha256 is required;

    submethod BUILD(Str() :$url, :$fetch-submodules, :$leave-dotGit, :$deepClone, :$rev, :$hash) is export {
        $!url = $url;
        my @opts = ($NIX-PREFETCH-GIT, '--url', $!url);
        push @opts, '--fetch-submodules' if $fetch-submodules;
        push @opts, '--leave-dotGit' if $leave-dotGit;
        push @opts, '--deepClone' if $deepClone;
        push @opts, '--rev', $rev if $rev.defined;
        push @opts, '--hash', $hash if $hash.defined;
        my $out = do given run(@opts, :out, :!err) {
            .sink unless .so;
            .out.slurp(:close)
        }
        ($!rev, $!sha256) = from-json($out)<rev sha256>;
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
