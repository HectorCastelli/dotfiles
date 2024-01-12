#!/bin/bash

# Getting a reference to the dotfiles repository
DOTFILES_DIR="$HOME/dotfiles"

# Installing bash aliases
ln -s "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"