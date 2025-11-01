#!/usr/bin/env bash
set -eu

if [ "$(uname)" = "Linux" ]; then
	flatpak uninstall -y flathub io.github.flattool.Warehouse 2>/dev/null || true
	flatpak uninstall -y io.github.kolunmi.Bazaar 2>/dev/null || true
	flatpak uninstall -y flathub page.tesk.Refine 2>/dev/null || true
	flatpak uninstall -y flathub com.mattjakeman.ExtensionManager 2>/dev/null || true
	flatpak uninstall -y flathub io.github.realmazharhussain.GdmSettings 2>/dev/null || true
elif [ "$(uname)" = "Darwin" ]; then
	# Nothing to do on macOS
	:
fi
