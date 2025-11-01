#!/usr/bin/env bash
set -eu

# Uninstall Spotify
if [ "$(uname)" = "Linux" ]; then
	flatpak uninstall -y flathub com.spotify.Client 2>/dev/null || true
elif [ "$(uname)" = "Darwin" ]; then
	brew uninstall --cask spotify 2>/dev/null || true
fi

# Uninstall Inkscape
if [ "$(uname)" = "Linux" ]; then
	flatpak uninstall -y flathub org.inkscape.Inkscape 2>/dev/null || true
elif [ "$(uname)" = "Darwin" ]; then
	brew uninstall --cask inkscape 2>/dev/null || true
fi

# Uninstall OBS Studio
if [ "$(uname)" = "Linux" ]; then
	flatpak uninstall -y flathub com.obsproject.Studio 2>/dev/null || true
elif [ "$(uname)" = "Darwin" ]; then
	brew uninstall --cask obs 2>/dev/null || true
fi
