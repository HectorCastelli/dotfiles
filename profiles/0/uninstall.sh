#!/usr/bin/env bash
set -u

# Check if brew is installed before attempting uninstall
if ! command -v brew >/dev/null 2>&1; then
	echo "Homebrew is not installed, nothing to uninstall"
	exit 0
fi

# Remove monaspace font
brew uninstall --cask font-monaspace-nf 2>/dev/null || true

# Remove unzip
brew uninstall unzip 2>/dev/null || true

# Remove coreutils (if installed with brew)
brew uninstall coreutils 2>/dev/null || true

# Remove starship prompt
brew uninstall starship 2>/dev/null || true

# Remove zsh (if installed with brew)
brew uninstall zsh 2>/dev/null || true

# Remove homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
