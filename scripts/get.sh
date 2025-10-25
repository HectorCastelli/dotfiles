#!/usr/bin/env sh
set -eu

check_dependencies() {
	required_commands="git curl sh bash which chsh"

	for cmd in $required_commands; do
		if ! command -v "$cmd" >/dev/null 2>&1; then
			printf "Error: required command '%s' is not installed.\n" "$cmd"
			return 1
		fi
	done

	return 0
}

install() {
	DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
	DOTFILES_REPO=${DOTFILES_REPO:-"https://github.com/HectorCastelli/dotfiles.git"}

	printf "Checking mandatory dependencies...\n"
	if ! check_dependencies; then
		printf "Error: missing required dependencies.\n"
		return 1
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
check)
	check_dependencies
	;;
help)
	USAGE="Usage:
$(basename "$0") <command>

Available commands:
	install	Installs the dotfiles repository
	check	Checks for required dependencies
	help	Show this help message"

	printf "%s\n" "$USAGE"
	;;
*)
	# script was sourced, so we do nothing.
	;;
esac
