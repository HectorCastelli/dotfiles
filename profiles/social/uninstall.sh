#!/usr/bin/env bash
set -eu

if [ "$(uname)" = "Linux" ]; then
	flatpak uninstall -y flathub com.discordapp.Discord 2>/dev/null || true
	flatpak uninstall -y flathub com.rtosta.zapzap 2>/dev/null || true
	flatpak uninstall -y org.telegram.desktop 2>/dev/null || true
elif [ "$(uname)" = "Darwin" ]; then
	brew uninstall --cask discord 2>/dev/null || true
	brew uninstall --cask whatsapp 2>/dev/null || true
	brew uninstall --cask telegram 2>/dev/null || true
fi
