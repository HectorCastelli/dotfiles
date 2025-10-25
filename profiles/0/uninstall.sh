#!/usr/bin/env bash
set -u

# Remove monaspace font
brew uninstall --cask font-monaspace-nf

# Remove unzip
brew uninstall unzip

# Remove coreutils (if installed with brew)
brew uninstall coreutils 2>/dev/null || true

# Remove starship prompt
brew uninstall starship

# Remove zsh (if installed with brew)
brew uninstall zsh

# Remove homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
