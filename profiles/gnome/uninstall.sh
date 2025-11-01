#!/usr/bin/env bash
set -eu

if [ "$(uname)" = "Linux" ]; then
	flatpak uninstall -y flathub io.github.flattool.Warehouse 2>/dev/null || true
	flatpak uninstall -y flathub org.gnome.baobab 2>/dev/null || true
	flatpak uninstall -y flathub org.gnome.tweaks 2>/dev/null || true
	flatpak uninstall -y flathub com.mattjakeman.ExtensionManager 2>/dev/null || true
elif [ "$(uname)" = "Darwin" ]; then
	# Nothing to do on macOS
	:
fi
