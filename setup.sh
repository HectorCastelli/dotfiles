#!/bin/bash

echo "Installing dotfiles"
git clone https://github.com/HectorCastelli/dotfiles dotfiles


# Getting a reference to the dotfiles repository
DOTFILES_DIR="$HOME/dotfiles"

# Install nix
sh <(curl -L https://nixos.org/nix/install)

# Setup sistem-wide packages with nix
source "$DOTFILES_DIR/nix/global.sh"

# Install starship prompt
curl -sS https://starship.rs/install.sh | sh

# Install shell aliases

# Create shell configs for common use-cases
# rust
# nodejs

# Installing bash aliases
ln -s "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"