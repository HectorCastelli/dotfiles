#!/usr/bin/env sh
set -eu

DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"

# Install gcc and make via homebrew
brew install gcc
brew install make

# Install rustup (Rust toolchain installer) via homebrew
brew install rustup

# Initialize rustup and install the default stable toolchain
rustup-init -y --default-toolchain stable

# Source cargo environment
. "$HOME/.cargo/env"