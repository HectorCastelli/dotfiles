#!/usr/bin/env sh
set -eu

brew install lnav
brew install lcov
brew install graphviz
brew install shellcheck
brew install shfmt

if [ "$(uname)" = "Linux" ]; then
	flatpak install flathub com.usebruno.Bruno
elif [ "$(uname)" = "Darwin" ]; then
	brew install --cask bruno
else
	echo "Error: unsupported operating system" >&2
	exit 1
fi

brew install gh

if ! gh auth status --hostname github.com >/dev/null 2>&1; then
	gh auth login --hostname github.com --scopes admin:ssh_signing_key
	gh auth refresh --hostname github.com --scopes admin:public_key
fi

gh ssh-key add "$TARGET_DIR/home/.ssh/id_ed25519.pub" --title "$(hostname) authentication" --type authentication
gh ssh-key add "$TARGET_DIR/home/.ssh/id_ed25519_signing.pub" --title "$(hostname) signing" --type signing
