use v6.d;
use CompUnit::Repository::Staging;

# Distribution::Path ignores META.info files, but we can manually set it
sub find-meta-file($dir) {
    ('META6.json', 'META.info').map({$dir.child($_)}).first: {$_ ~~ :f}
}

sub MAIN(:from(:$dist-prefix) = '.', :libs(:$libpath), :to(:$repo-prefix)!, :for(:$repo-name)!) {
    my $meta-file = find-meta-file($dist-prefix.IO);
    my $dist      = Distribution::Path.new($dist-prefix.IO, :$meta-file);

    my $meta = Rakudo::Internals::JSON.from-json($meta-file.slurp);
    if ($meta<builder>) {
        say "builder";
        my $builder-class =  first { .so },
            (try require ::("$meta<builder>")),
            (try require ::("Distribution::Builder::$meta<builder>")); # get rid of this hard-coded prefix variation eventually

        my $builder = $builder-class.new(:$meta);

        if $builder.can-build {
            $builder.build;
            exit;
        }
        else {
            note "Failed to build";
            exit 1;
        }
    }

    CompUnit::Repository::Staging.new(
        :prefix($repo-prefix),
        :next-repo(CompUnit::RepositoryRegistry.setup-repositories()),
        :name($repo-name),
    ).install($dist);

    $_.unlink for <repo.lock precomp/.lock>.map: {$repo-prefix.IO.child($_)};
}
