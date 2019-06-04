my token hex { <[0..9a..f]> }
my token path { .+ }
my token ref-spec { ｢ref: ｣ <path> }
my token hash { <hex> ** 40 }

class Commit { ... }
class Repo { ... }

#| Something that can be resolved to a Commit.
role Commitish {
    has Repo $.repo is required;

    #| Resolve one level of indirection.
    #| Examples:
    #| <HEAD> may resolve to <refs/heads/master>
    #| <refs/heads/master> may resolve to <2ccc20fb591ea3b55e41dee7f7fdb5494d0c71be>
    method deref(--> Commitish:D) { ... }

    #| Resolve to a precise Commit.
    method Commit(--> Commit:D) {
        my $obj = self;
        $obj .= deref until $obj ~~ Commit;
        $obj
    }

    #| Get the git-describe of the referenced Commit.
    method describe(*@globs) {
        my @cmd = |<git describe --tags>, |(|(<--match>, $_) for @globs), self.rev-id;
        .out.slurp(:close).chomp with run @cmd, :cwd($!repo.path), :out, :!err;
    }

    #| Obtain a readable handle to a file from a commit in the repo. Note that
    #| this doesn't reflect any changes in the working directory (if there is
    #| one). For that, use .workdir!
    #| The handle may be tied to a subprocess, so be sure to close it when you're done!
    method open(IO() $path --> IO::Handle) {
        given run <git show>, "{.rev-id}:{$path}", :cwd($!repo.path), :out {
            .sink unless .so;
            .out
        }
    }

    method rev-id(--> Str) { self.Str }

    method hash(Commitish:D: --> Str) { self.Commit.Str }

    method ancestor(Commitish:D: $distance = 1 --> Commit) {
        my $hash = do given run <git rev-list --max-count=1>, "--skip=$distance", self.rev-id, :cwd($!repo.path), :out {
            .sink unless .so;
            .out.slurp(:close).chomp
        };
        Commit.new(:repo($!repo), :$hash)
    }
    method parent(--> Commit) { self.ancestor }

    method gist(Commitish:D:) { $!repo.gist ~ ｢ @ ｣ ~ self.rev-id }

    #| Smartmatch tests whether two Commitishes (currently) resolve to Commits with the same hash.
    multi method ACCEPTS(Commitish:D: Commitish:D $lhs) { [eq] (self, $lhs)».Commit }
}

=begin pod
Set operators on Commitishes operate as if on the set of the head of the Commit
and all its ancestors.

Membership operators look for the head of one Commit in the history of the
other (which is equivalent to the non-strict subset operators).

If what you really want to know is whether you can fast-forward though, it's
better to try it (and avoid the TOCTOU race).

The intersection operator gives the "best" common ancestor (merge-base), which
can be Nil. I guess the union operator could git-merge, but I'm NOT
implementing that.
=end pod

# XXX: because Commitishes may be symbolic, there are some pitfalls to avoid
# when comparing them:
# - If the Commitishes to be compared aren't in the same repo, the one from the
#   "foreign" repo has to be resolved to ensure it doesn't change meanings.
# - Some operations, like testing subsetness, requires multiple operations.
#   If the repo were modified on-disk between operations, we could get an
#   answer that isn't consistent with the state before or after the change.
# So, always resolve a Commitish to a Commit before:
# - uses its name in reference to another repo
# - performing multiple operations on it that need to be consistent with each other

multi sub infix:<∈>(Commitish:D $a, Commitish:D $b --> Bool:D) {
    so run <git merge-base --is-ancestor>, $a.Commit, $b, :cwd($b.repo.path);
}
multi sub infix:<(elem)>(Commitish:D $a, Commitish:D $b --> Bool:D) { $a ∈ $b }
multi sub infix:<∉>(Commitish:D $a, Commitish:D $b --> Bool:D) { !($a ∈ $b) }
multi sub infix:<⊆>(Commitish:D $a, Commitish:D $b --> Bool:D) { $a ∈ $b }
multi sub infix:<⊈>(Commitish:D $a, Commitish:D $b --> Bool:D) { !($a ∈ $b) }

multi sub infix:<∋>(Commitish:D $a, Commitish:D $b --> Bool:D) { $b ∈ $a }
multi sub infix:<∌>(Commitish:D $a, Commitish:D $b --> Bool:D) { !($b ∈ $a) }
multi sub infix:<⊇>(Commitish:D $a, Commitish:D $b --> Bool:D) { $b ∈ $a }
multi sub infix:<⊉>(Commitish:D $a, Commitish:D $b --> Bool:D) { !($b ∈ $a) }

multi sub infix:<⊂>(Commitish:D $a is copy, Commitish:D $b is copy --> Bool:D) {
    ($a, $b)».=Commit;
    $a ne $b and $a ∈ $b
}
multi sub infix:<⊄>(Commitish:D $a is copy, Commitish:D $b is copy --> Bool:D) {
    ($a, $b)».=Commit;
    $a eq $b or !($a ∈ $b)
}
multi sub infix:<⊃>(Commitish:D $a is copy, Commitish:D $b is copy --> Bool:D) {
    ($a, $b)».=Commit;
    $b ne $a and $b ∈ $a
}
multi sub infix:<⊅>(Commitish:D $a is copy, Commitish:D $b is copy --> Bool:D) {
    ($a, $b)».=Commit;
    $b eq $a or !($b ∈ $a)
}

#| NB. This fails if the Commitishes are in two different repos and neither
#| contains both Commits. In that case, a complete comparison would require
#| creating a repo that does contain both commits, which is beyond the scope of
#| this operator.
#| If the commits are in the same repo but have no common ancestor, this will
#| currently also fail, but maybe returning Nil would be better?
multi sub infix:<∩>(Commitish:D $a is copy, Commitish:D $b is copy --> Commit) {
    # Try both repos in case only one contains both objects. Super dwimmy, but
    # intersection should be symmetric.
    ($a, $b)».=Commit;
    my $merge = run(<git merge-base>, $a, $b, :cwd($a.repo.path), :out);
    $merge ||= run(<git merge-base>, $a.Commit, $b, :cwd($b.repo.path), :out) if !($a.repo ~~ $b.repo);
    $merge.sink unless $merge;
    my $hash = $merge.out.slurp(:close).chomp;
    Commit($a.repo, :$hash)
}
multi sub infix:<(&)>(Commitish:D $a, Commitish:D $b --> Commit) { $a ∩ $b }
multi sub infix:<∪>(Commitish:D $a, Commitish:D $b --> Commit) { die ｢Union operator on Commitishes is unsupported.｣ }
multi sub infix:<(|)>(Commitish:D $a, Commitish:D $b --> Commit) { $a ∪ $b }

multi sub infix:<∖>(Commitish:D $_a, Commitish:D $_b --> Seq) {
    my $repo = $_a.repo;
    my ($a, $b) = $_a.rev-id, $_b.Commit;
    given run(<git rev-list>, "$b..$a", :cwd($repo.path), :out) {
        .sink unless .so;
        .out.lines.map: { Commit.new(:$repo, :hash($_)) }
    }
}
multi sub infix:<(-)>(Commitish:D $a, Commitish:D $b --> Seq) { $a ∖ $b }
multi sub infix:<..>(Commitish:D $a, Commitish:D $b --> Range:D) is assoc<non> { ... }
multi sub infix:<..^>(Commitish:D $a, Commitish:D $b --> Range:D) is assoc<non> { ... }
multi sub infix:<^..>(Commitish:D $a, Commitish:D $b --> Range:D) is assoc<non> { ... }
multi sub infix:<^..^>(Commitish:D $a, Commitish:D $b --> Range:D) is assoc<non> { ... }

#| A precise commit in a particular Repo, identified by full hash.
class Commit does Commitish {
    has Str $.hash is required where /^<hash>$/;
    submethod BUILD(Str() :$!hash, :$!repo) {}
    method Str() { $!hash }
    method deref(--> Commit:D) { self }
    method gist(Commit:D:) { $!repo.gist ~ ｢ @ ｣ ~ $!hash.substr(0, 6) }
}

#| The head of a named branch in a particular Repo.
#| What this refers to can be changed by operations like git-pull.
class Branch does Commitish {
    has Str $.name is required;
    submethod BUILD(Str() :$!name, :$!repo) {}
    method Str() { "refs/heads/$!name" }
    method deref(--> Commit:D) { $!repo.resolve(self) }
}

#| The HEAD of a Repo.
#| What this refers to can be changed by operations like git-checkout or git-pull.
class Head does Commitish {
    method Str(--> ｢HEAD｣) {}
    method deref(--> Commitish:D) { $!repo.read-head(<HEAD>) }
}

class Repo does Commitish {
    has IO $.path is required where *.d;
    has Str $.url;
    has Bool $.bare;

    submethod BUILD(:$!path = $*CWD, Bool() :$!bare) { $!repo = self; }

    method gist(Repo:D: --> Str:D) { $!path.basename }

    method Str(Repo:D: --> Str:D) { "Repo<{$!path.basename}>" }

    method !dotgit() { $!bare ?? $!path !! $!path.add(".git") }

    #| Return the working directory, or Nil if the repo is bare.
    method workdir(--> IO) { $!bare ?? Nil !! $!path }

    #| When treated as a Commit, a Repo acts like its HEAD.
    method deref(--> Commitish:D) { self.head.deref }

    #| Get an object that explicitly refers to the HEAD.
    method head(--> Head:D) { Head.new(:repo(self)) }

    method rev-id(Repo:D: --> Str:D) { self.head.Str }

    #| Get an object that refers to a particular branch.
    method branch(Str() $name --> Branch:D) { Branch.new(:repo(self), :$name) }

    #| Dereference a fully-spelled out rev (e.g. refs/heads/master).
    method resolve(Str() $ref --> Commitish) {
        # XXX in the event of a racing modification to the repo, we might die from a false negative here
        my $hash = do
            # try looking for a file with that name
            with self!dotgit.add($ref).slurp { .chomp }
            # see if it occurs in full as a packed-ref
            orwith self!dotgit.add(<packed-refs>).slurp ~~ m/^^<hash> ｢ ｣ $($ref)$$/ { $/<hash>.Str };
        Commit.new(:repo(self), :$hash);
    }

    #| Read the rev specified in a dotgit-relative path (e.g. HEAD).
    method read-head(IO() $path --> Commitish) {
        given self!dotgit.add($path).slurp.chomp {
            when /^<hash>$/ { Commit.new(:repo(self), :hash($_)); }
            when /^<ref-spec>$/ {
                given $/<ref-spec><path>.Str {
                    when m!^｢refs/heads/｣(.*)! { Branch.new(:repo(self), :name($0)) }
                    default { die }
                }
            }
            default { die }
        }
    }

    #| Set HEAD to the Commitish, updating the working tree (if there is one).
    multi method checkout(Commitish:D $rev) { run <git checkout -q>, $rev, :cwd($!path) }

    #| Get the commit referred to by a remote head.
    method fetch(Str() :$remote = ｢origin｣, Str() :$branch = ｢master｣ --> Commit) {
        # XXX in the event of a race, e.g. with another git-fetch, this could
        # give a completely wrong answer! Unfortunately git-fetch offers no
        # option to output the remote's hash. Consequently, if the end goal is
        # to pull the branch it is better to do so directly.
        run <git fetch -q>, $remote, $branch, :cwd($!path);
        my $hash = self!dotgit.add(<FETCH_HEAD>).slurp.split("\t").first;
        Commit.new(:repo(self), :$hash)
    }

    #| Update the current HEAD to the given Commitish, so long as Commitish contains HEAD.
    method fast-forward(Commitish:D $to) {
        run <git merge --ff --ff-only -q>, $to, :cwd($!path);
    }

    #| Update the specified branch.
    method pull(:$origin = ｢origin｣, :$branch = ｢master｣) {
        run <git pull -q>, $origin, $branch, :cwd($!path);
    }

    #| Smartmatch tests whether two Repos are (currently) operating in the
    #| same git directory. This ignores other properties of the Repo, and even
    #| whether one of them is a symlink.
    #| NB. This in not the way to tell if two Repos "are checkouts of the same
    #| thing", which is a somewhat complex question.
    multi method ACCEPTS(Repo:D: Repo:D $lhs) { [~~] (self, $lhs).map: *.dotgit.resolve(:completely) }

    method clone($url, :$path --> Repo:D) {
        $path.mkdir;
        run <git clone --bare --single-branch -q -->, $url, $path;
        self.new(:$path)
    }
}

# need to offer an interface to:
# - idempotently clone or checkout-fetch-pull to get the current origin/master Commit
# clone($url, :$branch, :bare, :allow-exists, :allow-checkout, :allow-non-ff)

sub MAIN() {
    my $moar = Repo.new(:path(</var/cache/a/MoarVM>.IO));
    say $moar.rev-id;
    .say for $moar ∖ $moar.ancestor(4);
    exit;

    say "head: " ~ $moar.Commit;
    say "is head on master? " ~ ($moar.Commit ∈ $moar.branch(<master>));
    say "checking out master...";
    $moar.checkout($moar.branch(<master>));
    say "head: " ~ $moar.Commit;
    with $moar.workdir { say "workdir: $_" };

    my $fetched = $moar.fetch;
    say "fetch: $fetched";
    if $moar ~~ $fetched {
        say "already up to date";
    } else {
        $moar.fast-forward($fetched);
        say "head: " ~ $moar.Commit;
    }

    my $xml = Repo.new(:path(</home/kaz/a/exemel.git>.IO), :bare);
    say $xml.head;
    say $xml.head.deref;
    say $xml.head.Commit;
    say $xml.open("META6.json").slurp(:close);
    with $xml.workdir { say "workdir: $_" };
}
