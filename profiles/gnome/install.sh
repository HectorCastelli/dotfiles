#!/usr/bin/env sh
set -eu

if [ "$(uname)" = "Linux" ]; then
	flatpak install -y flathub io.github.flattool.Warehouse
	flatpak install -y flathub io.github.kolunmi.Bazaar
	flatpak install -y flathub page.tesk.Refine
	flatpak install -y flathub com.mattjakeman.ExtensionManager
	flatpak install -y flathub io.github.realmazharhussain.GdmSettings
elif [ "$(uname)" = "Darwin" ]; then
	echo "GNOME does not run on macOS. Skipping installation."
fi
