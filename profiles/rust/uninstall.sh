#!/usr/bin/env sh
set -eu

# Uninstall rustup and all Rust toolchains
if command -v rustup >/dev/null 2>&1; then
	rustup self uninstall -y
fi

# Remove any remaining Rust-related files
rm -rf "$HOME/.cargo" 2>/dev/null || true
rm -rf "$HOME/.rustup" 2>/dev/null || true

# Uninstall make and gcc via homebrew
brew uninstall make 2>/dev/null || true
brew uninstall gcc 2>/dev/null || true
