#!/usr/bin/env sh
set -eu

# Install Spotify
if [ "$(uname)" = "Linux" ]; then
	flatpak install -y flathub com.spotify.Client
elif [ "$(uname)" = "Darwin" ]; then
	brew install --cask spotify
fi

# Install Inkscape
if [ "$(uname)" = "Linux" ]; then
	flatpak install -y flathub org.inkscape.Inkscape
elif [ "$(uname)" = "Darwin" ]; then
	brew install --cask inkscape
fi

# Install OBS Studio
if [ "$(uname)" = "Linux" ]; then
	flatpak install -y flathub com.obsproject.Studio
elif [ "$(uname)" = "Darwin" ]; then
	brew install --cask obs
fi

# Motrix
if [ "$(uname)" = "Linux" ]; then
	flatpak install -y flathub net.agalwood.Motrix
elif [ "$(uname)" = "Darwin" ]; then
	brew install --cask motrix
fi
