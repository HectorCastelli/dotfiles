#!/usr/bin/env bash
set -eu

# Uninstall Calibre
if [ "$(uname)" = "Linux" ]; then
	flatpak uninstall -y flathub com.calibre_ebook.calibre 2>/dev/null || true
elif [ "$(uname)" = "Darwin" ]; then
	brew uninstall --cask calibre 2>/dev/null || true
fi

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

# Motrix
if [ "$(uname)" = "Linux" ]; then
	flatpak uninstall -y flathub net.agalwood.Motrix 2>/dev/null || true
elif [ "$(uname)" = "Darwin" ]; then
	brew uninstall --cask motrix 2>/dev/null || true
fi
