#!/bin/sh

nix-shell -p "rakudo.withPackages(p6: with p6; [Gumbo JSON-Tiny LibraryCheck LWP-Simple MIME-Base64 Readline URI XML])"
