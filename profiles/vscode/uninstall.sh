#!/usr/bin/env bash
set -eu

if [ "$(uname)" = "Linux" ]; then
	sudo dnf remove -y code 2>/dev/null || true
else
	brew uninstall --cask visual-studio-code 2>/dev/null || true
fi
