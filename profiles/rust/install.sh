#!/usr/bin/env sh
set -eu

# Install gcc and make via homebrew
brew install gcc
brew install make

# Install rustup (Rust toolchain installer) via homebrew
brew install rustup

# Initialize rustup and install the default stable toolchain
rustup-init -y --default-toolchain stable

# Verify installation
rustc --version
cargo --version
