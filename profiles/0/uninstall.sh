#!/usr/bin/env bash
set -u

# Check if brew is installed before attempting uninstall
if ! command -v brew >/dev/null 2>&1; then
	echo "Homebrew is not installed, nothing to uninstall"
	exit 0
fi

# Remove VSCode
brew uninstall --cask visual-studio-code 2>/dev/null || true

# Remove password manager
brew uninstall bitwarden-cli 2>/dev/null || true
brew uninstall --cask bitwarden 2>/dev/null || true

# Remove cli utilities
cli_utils="bat jq yq viddy glow tlrc"
for util in $cli_utils; do
	brew uninstall "$util" 2>/dev/null || true
done

# Do not remove SSH Identities, since they may be in use

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
