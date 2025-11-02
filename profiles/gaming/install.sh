#!/usr/bin/env sh
set -eu

if [ "$(uname)" = "Linux" ]; then
	# Steam
	flatpak install -y flathub com.valvesoftware.Steam

	sudo dnf install -y steam-devices

	# Wine (via Bottles which includes Wine)
	flatpak install -y flathub com.usebottles.bottles

	# Heroic Games Launcher (supports Epic, GOG, and Amazon Prime Gaming)
	flatpak install -y flathub com.heroicgameslauncher.hgl

	# PPSSPP (PSP emulator)
	flatpak install -y flathub org.ppsspp.PPSSPP

	# Steam ROM Manager
	flatpak install -y flathub com.steamgriddb.steam-rom-manager

	# Luanti (formerly Minetest)
	flatpak install -y flathub net.minetest.Minetest

	# Note: webkit2gtk4 and winetricks are typically installed as dependencies
	# or available through system package managers. Bottles includes winetricks functionality.

elif [ "$(uname)" = "Darwin" ]; then
	# Steam
	brew install --cask steam

	# Wine
	brew install --cask wine-stable

	# Winetricks
	brew install winetricks

	# Heroic Games Launcher
	brew install --cask heroic

	# PPSSPP
	brew install --cask ppsspp

	# Luanti (formerly Minetest)
	brew install --cask minetest

	# Note: Steam ROM Manager and GOG Galaxy have limited macOS support
	# webkit2gtk4 is not needed on macOS
fi
