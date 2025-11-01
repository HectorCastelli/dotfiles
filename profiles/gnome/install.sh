#!/usr/bin/env sh
set -eu

if [ "$(uname)" = "Linux" ]; then
	flatpak install -y flathub io.github.flattool.Warehouse
	flatpak install -y flathub org.gnome.baobab
	flatpak install -y flathub org.gnome.tweaks
	flatpak install -y flathub com.mattjakeman.ExtensionManager
elif [ "$(uname)" = "Darwin" ]; then
	echo "GNOME does not run on macOS. Skipping installation."
fi
