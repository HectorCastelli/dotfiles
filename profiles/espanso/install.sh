#!/usr/bin/env sh
set -eu

DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"

if [ "$(uname)" = "Linux" ]; then
	# Fedora-based
	if command -v dnf >/dev/null 2>&1; then
		# Install requeriments
		sudo dnf install -y @development-tools gcc-c++ wl-clipboard libxkbcommon-devel dbus-devel wxGTK-devel.x86_64

		# Build espanso from source
		mkdir -p "$TARGET_DIR/build"
		git clone https://github.com/espanso/espanso "$TARGET_DIR/build/espanso"

		# Install espanso
		cd "$TARGET_DIR/build/espanso" || exit 1
		if [ "${XDG_SESSION_TYPE:-}" = "x11" ] || [ "${DISPLAY:-}" != "" ]; then
			cargo build -p espanso --release --no-default-features --features vendored-tls,modulo
			sudo mv "$TARGET_DIR/build/espanso/target/release/espanso" "$TARGET_DIR/home/.local/bin/espanso"
		else
			cargo build -p espanso --release --no-default-features --features modulo,vendored-tls,wayland
			sudo mv "$TARGET_DIR/build/espanso/target/release/espanso" "$TARGET_DIR/home/.local/bin/espanso"
			sudo setcap "cap_dac_override+p" $(which espanso)
		fi
		cd -

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
