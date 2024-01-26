#!/bin/zsh

# Global variables
export DOTFILES_DIR="$HOME/dotfiles"
export DOTFILES_SHELL="$HOME/dotfiles/shell"

# Nix configuration
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi