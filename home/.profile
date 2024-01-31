#!/bin/sh

# Add global scripts to path
export PATH="$HOME/dotfiles/bin:$PATH"


if [ "$(uname)" = "Linux" ]; then
    if [ -d "$HOME/.nix-profile/share" ]; then
        # set PATH so it includes user's private bin if it exists
        XDG_DATA_DIRS=$HOME/.nix-profile/share:$XDG_DATA_DIRS
    fi
    if [ -d "/nix/var/nix/profiles/default/share" ]; then
        # set PATH so it includes user's private bin if it exists
        XDG_DATA_DIRS=/nix/var/nix/profiles/default/share:$XDG_DATA_DIRS
    fi
fi
