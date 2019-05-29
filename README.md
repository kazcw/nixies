My [Nix](https://nixos.org) overlays.

# Perl6 (Rakudo)

The perl6 overlay has smoke-tested nightly(-ish) builds of:
- rakudo (and its dependencies &lt;nqp MoarVM&gt;)
- zef
- Some perl6 modules:
    - Readline
    - JSON::Tiny
    - LWP::Simple
    - Gumbo
    - [and more](perl6.nix/)...

I'm adding modules as I need them. If anything you need is missing, you can
also install user packages with regular `zef install`, but you'll miss out on
all the awesomeness of Nix... or wrap the module! Look at
[readline.nix](perl6.nix/readline.nix) and
[perl6-packages.nix](perl6.nix/perl6-packages.nix) to see how its done.

## Usage

```sh
git clone git://github.com/kazcw/nixies

# add perl6 to your overlays
mkdir -p ~/.config/nixpkgs/overlays && ln -s $PWD/nixies/perl6.nix ~/.config/nixpkgs/overlays

# have fun!

# download and parse some HTML
nix-shell -p "rakudo.withPackages(p6: with p6; [Gumbo LWP-Simple])" --run "perl6 -MGumbo -MLWP::Simple -e 'say parse-html(LWP::Simple.get(\"http://www.google.com\")).lookfor(:TAG<title>)[0]'"

# get a nice shell
nix-shell -p "rakudo.withPackages(p6: [p6.Readline])" --run perl6
```
