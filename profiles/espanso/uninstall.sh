#!/usr/bin/env bash
set -eu

if [ "$(uname)" = "Linux" ]; then
	espanso service unregister 2>/dev/null || true
	espanso stop 2>/dev/null || true
	# Fedora-based
	if command -v dnf >/dev/null 2>&1; then
		dnf remove espanso-x11 espanso-wayland -y 2>/dev/null || true
	fi
elif [ "$(uname)" = "Darwin" ]; then
	brew uninstall --cask espanso 2>/dev/null || true
fi
