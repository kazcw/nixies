My [Nix](https://nixos.org) overlays.

# Perl6 (Rakudo)

The perl6 overlay has smoke-tested nightly(-ish) builds of:
- rakudo (and its dependencies &lt;nqp MoarVM&gt;)
- zef
- Some perl6 modules available through zef: &lt;Readline JSON::Tiny ...&gt;

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

# enjoy!
nix-shell -p "rakudo.withPackages(p6: [p6.Readline])" --run perl6
```
