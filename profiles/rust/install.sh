#!/usr/bin/env sh
set -eu

# Install gcc and make via homebrew
brew install gcc
brew install make

# Install rustup (Rust toolchain installer)
# Check if rustup is already installed
if ! command -v rustup >/dev/null 2>&1; then
	# Install rustup in non-interactive mode with default settings
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
	
	# Source the cargo environment to make rust tools available in this session
	# shellcheck source=/dev/null
	. "$HOME/.cargo/env"
else
	echo "rustup is already installed, updating..."
	rustup update
fi

# Verify installation
rustc --version
cargo --version
