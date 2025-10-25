#!/usr/bin/env sh
set -eu

install() {
	DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
	DOTFILES_REPO=${DOTFILES_REPO:-"https://github.com/HectorCastelli/dotfiles.git"}

	printf "Checking mandatory dependencies...\n"
	missing_commands=""

	for cmd in curl sh git; do
		if ! command -v "$cmd" >/dev/null 2>&1; then
			if [ -z "$missing_commands" ]; then
				missing_commands="$cmd"
			else
				missing_commands="$missing_commands $cmd"
			fi
		fi
	done

	if [ -n "$missing_commands" ]; then
		printf "Error: required commands missing: %s\n" "$missing_commands"
		printf "Please install the missing command(s) and try again.\n"
		exit 1
	fi

	printf "Target directory: %s\n" "$DOTFILES_DIR"

	if [ -e "$DOTFILES_DIR" ]; then
		printf "Error: target '%s' already exists.\n" "$DOTFILES_DIR"
		printf "If you intended to update an existing clone, run:\n  git -C %s pull\n" "$DOTFILES_DIR"
		exit 1
	fi

	printf "Cloning %s into %s ...\n" "$DOTFILES_REPO" "$DOTFILES_DIR"

	if git clone "$DOTFILES_REPO" "$DOTFILES_DIR"; then
		printf "Clone successful.\n"
	else
		printf "Error: git clone failed.\n"
		return 2
	fi

	printf "Running installation script...\n"
	if sh "$DOTFILES_DIR/scripts/install.sh"; then
		printf "Installation script completed successfully.\n"
		return 0
	else
		printf "Error: installation script failed.\n"
		return 3
	fi
}

case "${1:-}" in
install)
	install
	;;
help)
	USAGE="Usage:
$(basename "$0") <command>

Available commands:
	install	Installs the dotfiles repository
	help	Show this help message"

	printf "%s\n" "$USAGE"
	;;
*)
	# script was sourced, so we do nothing.
	;;
esac
