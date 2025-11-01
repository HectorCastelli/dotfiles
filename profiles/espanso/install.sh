#!/usr/bin/env sh
set -eu

if [ "$(uname)" = "Linux" ]; then
	# Fedora-based
	if command -v dnf >/dev/null 2>&1; then
		# Add terra repository
		dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release-$(rpm -E %fedora).noarch.rpm -y
		# Install espanso
		if [ "${XDG_SESSION_TYPE:-}" = "x11" ] || [ "${DISPLAY:-}" != "" ]; then
			dnf install espanso-x11 -y
		else
			# Assume Wayland
			dnf install espanso-wayland -y
		fi
		# Register espanso as a systemd service (required only once)
		espanso service register
		# Start espanso
		espanso start || echo "Failed to start espanso service. This may be fixed with a reboot."
	else
		echo "Error: This Linux system is not supported"
		exit 1
	fi
elif [ "$(uname)" = "Darwin" ]; then
	brew install --cask espanso
fi
