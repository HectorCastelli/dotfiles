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
