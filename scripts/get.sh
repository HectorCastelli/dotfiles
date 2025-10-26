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
		return 2
	fi

	printf "Cloning %s into %s ...\n" "$DOTFILES_REPO" "$DOTFILES_DIR"

	if git clone "$DOTFILES_REPO" "$DOTFILES_DIR"; then
		printf "Clone successful.\n"
	else
		printf "Error: git clone failed.\n"
		return 3
	fi

	printf "Initializing target directory...\n"
	if sh "$DOTFILES_DIR/scripts/target.sh initialize"; then
		printf "Target directory initialized successfully.\n"
	else
		printf "Error: target directory initialization failed.\n"
		return 4
	fi

	printf "Installing all mandatory profiles...\n"
	MANDATORY_PROFILES="$("$DOTFILES_DIR/scripts/profiles.sh" list_mandatory)"
	for profile in $MANDATORY_PROFILES; do
		if sh "$DOTFILES_DIR/scripts/target.sh" install_profile "$profile"; then
			printf "Installed mandatory profile: %s\n" "$profile"
		else
			printf "Error: failed to install mandatory profile '%s'.\n" "$profile"
			return 5
		fi
	done

	OPTIONAL_PROFILES="$("$DOTFILES_DIR/scripts/profiles.sh" list_optional)"
	for profile in $OPTIONAL_PROFILES; do
		printf "Optional profile available: %s\n" "$profile"
		printf "Would you like to install '%s'? [y/N]: " "$profile"
		if ! IFS= read -r ans; then
			ans=""
		fi
		case "$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')" in
		y | yes)
			if sh "$DOTFILES_DIR/scripts/profiles.sh" run_prompt "$profile"; then
				printf "Prompt for optional profile '%s' completed.\n" "$profile"
			else
				printf "Warning: prompt for optional profile '%s' failed or was skipped.\n" "$profile"
				return 6
			fi
			if sh "$DOTFILES_DIR/scripts/target.sh" install_profile "$profile"; then
				printf "Installed optional profile: %s\n" "$profile"
			else
				printf "Error: failed to install optional profile '%s'.\n" "$profile"
				return 7
			fi
			;;
		*)
			printf "Skipped optional profile: %s\n" "$profile"
			;;
		esac
	done

	# TODO: Show final state of the target with diff command
	# TODO: Ask for approval and apply the target if approved
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
