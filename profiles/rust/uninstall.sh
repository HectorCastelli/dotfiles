#!/usr/bin/env sh
set -eu

# Uninstall rustup via homebrew
brew uninstall rustup 2>/dev/null || true

# Remove any remaining Rust-related files
rm -rf "$HOME/.cargo" 2>/dev/null || true
rm -rf "$HOME/.rustup" 2>/dev/null || true

# Uninstall make and gcc via homebrew
brew uninstall make 2>/dev/null || true
brew uninstall gcc 2>/dev/null || true
