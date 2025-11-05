#!/usr/bin/env sh
set -eu

DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"

brew install fnm

# Install and use latest LTS version of Node.js
zsh -c "eval \"\$(fnm env --use-on-cd --shell=zsh)\" && \
    fnm install --lts && \
    fnm use lts-latest"
