#!/usr/bin/env sh
set -eu

if [ "$(uname)" = "Linux" ]; then
	# Steam
	sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
	sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
	sudo dnf install -y steam steam-devices
	sudo dnf install -y webkit2gtk4.1-devel wine winetricks

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
fi
