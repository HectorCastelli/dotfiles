#!/usr/bin/env sh
set -eu

initialize() {
	DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
	TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"

	if [ -d "$TARGET_DIR" ]; then
		if [ -d "$TARGET_DIR/.git" ]; then
			# Already a git repo, do nothing
			printf "Target directory already initialized as a git repository.\n"
			return 0
		else
			# Exists but not a git repo, remove it
			echo "Warning: $TARGET_DIR exists but is not a git repository."
			echo "This is unexpected. Please delete the directory manually before proceeding."
			return 1
		fi
	fi

	git init "$TARGET_DIR"
	touch "$TARGET_DIR/.dotfiles_profiles"
	save
}

clean() {
	DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
	TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"

	if [ ! -d "$TARGET_DIR" ]; then
		printf "Target directory does not exist. Nothing to clean.\n"
		return 0
	fi

	rm -rf "$TARGET_DIR"
	printf "Target directory '%s' has been removed.\n" "$TARGET_DIR"
}

save() {
	DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
	TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"
	timestamp="$(date +"%Y-%m-%d %H:%M:%S")"

	cd "$TARGET_DIR"
	git add -A
	git commit -m "Save $timestamp" || true

	printf "Saved changes to target directory at %s\n" "$timestamp"
}

discard() {
	DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
	TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"

	cd "$TARGET_DIR"
	git reset --hard HEAD~1

	printf "Discarded uncommitted changes in target directory.\n"
	printf "Reverted to previous commit: %s\n" "$(git rev-parse HEAD)"
}

install_profile() {
	profile="${1:-}"
	if [ -z "$profile" ]; then
		echo "Error: profile name required." >&2
		return 1
	fi

	DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
	TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"
	PROFILE_DIR="$DOTFILES_DIR/profiles/$profile"

	if [ ! -d "$PROFILE_DIR" ]; then
		echo "Error: profile '$profile' not found." >&2
		return 2
	fi

	# Add profile name to .dotfiles_profiles (if not already present)
	profiles_file="$TARGET_DIR/.dotfiles_profiles"
	grep -qxF "$profile" "$profiles_file" 2>/dev/null || echo "$profile" >>"$profiles_file"

	# Copy install.sh
	profile_install="$PROFILE_DIR/install.sh"
	target_install="$TARGET_DIR/install.sh"
	if [ -f "$profile_install" ]; then
		if [ -f "$target_install" ]; then
			cat "$profile_install" >>"$target_install"
		else
			cp "$profile_install" "$target_install"
		fi
	fi

	# Copy home directory recursively
	profile_home="$PROFILE_DIR/home"
	target_home="$TARGET_DIR/home"
	if [ -d "$profile_home" ]; then
		mkdir -p "$target_home"
		cp -a "$profile_home/." "$target_home/"
	fi
}

uninstall_profile() {
	profile="${1:-}"
	if [ -z "$profile" ]; then
		echo "Error: profile name required." >&2
		return 1
	fi

	DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
	TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"
	profiles_file="$TARGET_DIR/.dotfiles_profiles"

	# Clean target_dir contents except .dotfiles_profiles and .git
	find "$TARGET_DIR" -mindepth 1 ! -name ".dotfiles_profiles" ! -name ".git" -exec rm -rf {} +

	# Remove profile from .dotfiles_profiles
	if [ -f "$profiles_file" ]; then
		grep -vxF "$profile" "$profiles_file" >"$profiles_file.tmp" && mv "$profiles_file.tmp" "$profiles_file"
	fi

	# Re-install all remaining profiles
	if [ -f "$profiles_file" ]; then
		while read -r p; do
			[ -n "$p" ] && install_profile "$p"
		done <"$profiles_file"
	fi
}

apply() {
	DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
	TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"
	TARGET_HOME="$TARGET_DIR/home"

	# Run install.sh from target dir if it exists
	if [ -f "$TARGET_DIR/install.sh" ]; then
		sh "$TARGET_DIR/install.sh"
	fi

	# Recursively symlink files/dirs from target_dir/home into $HOME
	find "$TARGET_HOME" -mindepth 1 | while read -r src; do
		rel_path="${src#"$TARGET_HOME"/}"
		dest="$HOME/$rel_path"

		# Ensure parent directory exists
		dest_dir="$(dirname "$dest")"
		mkdir -p "$dest_dir"

		if [ -e "$dest" ] || [ -L "$dest" ]; then
			# If already a symlink to the correct target, skip
			if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
				continue
			fi

			# If it's a symlink to somewhere else, or a file/dir, prompt
			echo "File '$dest' already exists."
			if [ -L "$dest" ]; then
				target="$(readlink "$dest")"
				if [ "$target" = "$src" ]; then
					continue
				fi
				echo "It is a symlink to '$target'."
			fi
			printf "Delete and replace with symlink to '%s'? [y/N]: " "$src"
			if ! IFS= read -r ans; then
				ans=""
			fi
			case "$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')" in
			y | yes)
				rm -rf "$dest"
				;;
			*)
				echo "Skipping '$dest'."
				continue
				;;
			esac
		fi

		ln -s "$src" "$dest"
	done
}

case "${1:-}" in
initialize)
	initialize
	;;
clean)
	clean
	;;
save)
	save
	;;
discard)
	discard
	;;
install_profile)
	shift
	install_profile "$@"
	;;
uninstall_profile)
	shift
	uninstall_profile "$@"
	;;
apply)
	apply
	;;
help)
	USAGE="Usage:
$(basename "$0") <command>

Available commands:
    initialize	Initializes the target directory for the first time if needed
	clean		Removes the target directory entirely
    save		Save the current state of the target directory as a commit
	discard		Discard uncommitted changes in the target directory
    install_profile	Install a profile into the target directory
	uninstall_profile	Uninstall a profile from the target directory
	apply		Apply the target directory to the home directory
    help		Show this help message"

	printf "%s\n" "$USAGE"
	;;
*)
	# script was sourced, so we do nothing.
	;;
esac
