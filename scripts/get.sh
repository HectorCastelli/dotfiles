#!/usr/bin/env sh
set -eu

check() {
	required_commands="git curl sh bash which chsh"

	for cmd in $required_commands; do
		if ! command -v "$cmd" >/dev/null 2>&1; then
			printf "Error: required command '%s' is not installed.\n" "$cmd"
			return 1
		fi
	done
}

extend_sudo_timeout() {
	# Check if already running (prevent duplicate processes)
	if [ -n "${SUDO_KEEPER_PID:-}" ] && kill -0 "$SUDO_KEEPER_PID" 2>/dev/null; then
		# Sudo keeper already running, nothing to do
		return 0
	fi

	# Check if sudo is available and we're on a system that uses it
	if ! command -v sudo >/dev/null 2>&1; then
		# sudo not available, nothing to do
		return 0
	fi

	# Prompt for sudo credentials once to extend the timeout
	# This reduces password prompts during the installation process
	printf "Some installation steps require administrative privileges.\n"
	printf "Please enter your password to proceed (you won't be asked again for a while):\n"
	if sudo -v; then
		# Keep sudo session alive in background
		# This updates the timestamp every 60 seconds (configurable via SUDO_REFRESH_INTERVAL)
		(
			interval="${SUDO_REFRESH_INTERVAL:-60}"
			while true; do
				sleep "$interval"
				sudo -n true 2>/dev/null || exit
			done
		) &
		SUDO_KEEPER_PID=$!
		# Set up cleanup trap to kill the background process
		trap 'kill "$SUDO_KEEPER_PID" 2>/dev/null || true' EXIT INT TERM
		printf "Sudo session extended. (PID: %s)\n" "$SUDO_KEEPER_PID"
	else
		printf "Warning: Failed to authenticate with sudo. Installation may prompt for password multiple times.\n"
		return 1
	fi
}

get() {
	DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
	DOTFILES_REPO=${DOTFILES_REPO:-"https://github.com/HectorCastelli/dotfiles.git"}

	printf "Checking mandatory dependencies...\n"
	if ! check; then
		printf "Error: missing required dependencies.\n"
		return 1
	else
		printf "All required dependencies are installed.\n"
	fi

	# Extend sudo timeout to reduce password prompts during installation
	extend_sudo_timeout

	if [ -d "$DOTFILES_DIR" ]; then
		if [ -d "$DOTFILES_DIR/.git" ]; then
			CURRENT_REMOTE=$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null || echo "")
			if [ "$CURRENT_REMOTE" = "$DOTFILES_REPO" ]; then
				printf "Directory '%s' is already a git repository pointing to the correct remote.\n" "$DOTFILES_DIR"
				printf "Would you like to update it instead? [y/N]: "
				read -r update_ans </dev/tty
				case "$(printf '%s' "$update_ans" | tr '[:upper:]' '[:lower:]')" in
				y | yes)
					printf "Updating existing repository...\n"
					if git -C "$DOTFILES_DIR" pull; then
						printf "Update successful.\n"
					else
						printf "Error: git pull failed.\n"
						return 2
					fi
					;;
				*)
					printf "Update skipped.\n"
					;;
				esac
			else
				printf "Error: '%s' is a git repository but points to a different remote.\n" "$DOTFILES_DIR"
				printf "Current remote: %s\n" "$CURRENT_REMOTE"
				printf "Expected remote: %s\n" "$DOTFILES_REPO"
				return 3
			fi
		else
			printf "Error: '%s' exists but is not a git repository.\n" "$DOTFILES_DIR"
			return 4
		fi
	else

		printf "Cloning %s into %s ...\n" "$DOTFILES_REPO" "$DOTFILES_DIR"

		if git clone "$DOTFILES_REPO" "$DOTFILES_DIR"; then
			printf "Clone successful.\n"
		else
			printf "Error: git clone failed.\n"
			return 5
		fi
	fi

	# Pull submodules
	if git -C "$DOTFILES_DIR" submodule update --init --recursive --remote; then
		printf "Submodules updated successfully.\n"
	else
		printf "Error: failed to update submodules.\n"
		return 6
	fi

	install
}

install() {
	DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
	TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"

	# Extend sudo timeout to reduce password prompts during installation
	extend_sudo_timeout

	printf "Initializing target directory...\n"
	if sh "$DOTFILES_DIR/scripts/target.sh" initialize; then
		printf "Target directory initialized successfully.\n"
	else
		printf "Error: target directory initialization failed.\n"
		return 1
	fi

	PROFILES=$("$DOTFILES_DIR/scripts/profiles.sh" list)
	for profile in $PROFILES; do
		if [ ! -f "$DOTFILES_DIR/profiles/$profile/.mandatory" ]; then
			printf "Optional profile available: %s\n" "$profile"
			printf "Would you like to install '%s'? [y/N]: " "$profile"
			read -r ans </dev/tty
			case "$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')" in
			y | yes) ;;
			*)
				printf "Skipped optional profile: %s\n" "$profile"
				continue
				;;
			esac
		else
			printf "Profile '%s' is mandatory.\n" "$profile"
		fi
		if sh "$DOTFILES_DIR/scripts/target.sh" install_profile "$profile"; then
			printf "Installed mandatory profile: %s\n" "$profile"
		else
			printf "Error: failed to install mandatory profile '%s'.\n" "$profile"
			return 2
		fi
	done

	printf "Building target configuration...\n"
	if sh "$DOTFILES_DIR/scripts/target.sh" build; then
		printf "Target configuration built successfully.\n"
	else
		printf "Error: failed to build target configuration.\n"
		return 3
	fi

	printf "If you would like to review the target first, please look into the '%s' directory.\n" "$TARGET_DIR"
	printf "Do you want to proceed with the installation? [y/N]: "
	read -r apply_ans </dev/tty
	case "$(printf '%s' "$apply_ans" | tr '[:upper:]' '[:lower:]')" in
	y | yes)
		printf "Applying target configuration...\n"
		if sh "$DOTFILES_DIR/scripts/target.sh" apply; then
			printf "Target configuration applied successfully.\n"
		else
			printf "Error: failed to apply target configuration.\n"
			return 4
		fi
		;;
	*)
		printf "Installation skipped. You can apply the configuration later by running:\n"
		printf "  sh %s/scripts/target.sh apply\n" "$DOTFILES_DIR"
		;;
	esac
}

case "${1:-}" in
get)
	get
	;;
install)
	install
	;;
check)
	check
	;;
help)
	USAGE="Usage:
$(basename "$0") <command>

Available commands:
	get		Download the dotfiles repository, then installs it
	install	Installs the dotfiles repository
	check	Checks for required dependencies
	help	Show this help message"

	printf "%s\n" "$USAGE"
	;;
*)
	# script was sourced, so we do nothing.
	;;
esac
