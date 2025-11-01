#!/usr/bin/env bash
set -eu

if [ "$(uname)" = "Linux" ]; then
	sudo flatpak uninstall --yes com.usebruno.Bruno 2>/dev/null || true
elif [ "$(uname)" = "Darwin" ]; then
	brew uninstall --cask bruno 2>/dev/null || true
fi

brew uninstall gh 2>/dev/null || true
brew uninstall shfmt 2>/dev/null || true
brew uninstall shellcheck 2>/dev/null || true
brew uninstall graphviz 2>/dev/null || true
brew uninstall lcov 2>/dev/null || true
brew uninstall lnav 2>/dev/null || true
