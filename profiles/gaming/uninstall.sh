#!/usr/bin/env bash
set -eu

if [ "$(uname)" = "Linux" ]; then
	flatpak uninstall -y flathub net.minetest.Minetest 2>/dev/null || true
	flatpak uninstall -y flathub com.steamgriddb.steam-rom-manager 2>/dev/null || true
	flatpak uninstall -y flathub org.ppsspp.PPSSPP 2>/dev/null || true
	flatpak uninstall -y flathub com.heroicgameslauncher.hgl 2>/dev/null || true
	flatpak uninstall -y flathub com.usebottles.bottles 2>/dev/null || true
	flatpak uninstall -y flathub com.valvesoftware.Steam 2>/dev/null || true
elif [ "$(uname)" = "Darwin" ]; then
	brew uninstall --cask minetest 2>/dev/null || true
	brew uninstall --cask ppsspp 2>/dev/null || true
	brew uninstall --cask heroic 2>/dev/null || true
	brew uninstall winetricks 2>/dev/null || true
	brew uninstall --cask wine-stable 2>/dev/null || true
	brew uninstall --cask steam 2>/dev/null || true
fi
