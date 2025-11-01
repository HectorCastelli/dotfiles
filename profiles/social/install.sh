#!/usr/bin/env sh
set -eu

if [ "$(uname)" = "Linux" ]; then
	flatpak install -y flathub com.discordapp.Discord
elif [ "$(uname)" = "Darwin" ]; then
	brew install --cask discord
else
	echo "Error: unsupported operating system" >&2
	exit 1
fi

if [ "$(uname)" = "Linux" ]; then
	flatpak install -y flathub com.rtosta.zapzap
elif [ "$(uname)" = "Darwin" ]; then
	brew install --cask whatsapp
else
	echo "Error: unsupported operating system" >&2
	exit 1
fi
