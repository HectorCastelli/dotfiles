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

	git init --initial-branch main "$TARGET_DIR"
	touch "$TARGET_DIR/.dotfiles_profiles"
	save
}

remove() {
	DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
	TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"

	if [ ! -d "$TARGET_DIR" ]; then
		printf "Target directory does not exist. Nothing to remove.\n"
		return 0
	fi

	clean

	rm -rf "$TARGET_DIR"
	printf "Target directory '%s' has been removed.\n" "$TARGET_DIR"
}

save() {
	DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
	TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"
	timestamp="$(date +"%Y-%m-%d %H:%M:%S")"

	cd "$TARGET_DIR"

	# Ensure git user is configured for this repository
	if [ -z "$(git config user.name 2>/dev/null || true)" ]; then
		git config user.name "Dotfiles Manager"
	fi
	if [ -z "$(git config user.email 2>/dev/null || true)" ]; then
		git config user.email "dotfiles@localhost"
	fi

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

	# Launch profile's install prompt if it exists
	if [ -f "$PROFILE_DIR/prompt.sh" ]; then
		# Load existing answers.env or initialize it
		if [ ! -f "$TARGET_DIR/answers.env" ]; then
			touch "$TARGET_DIR/answers.env"
		fi
		set -a
		# shellcheck source=/dev/null
		. "$TARGET_DIR/answers.env" || true
		set +a
		if output="$(sh "$PROFILE_DIR/prompt.sh")"; then
			printf '%s\n' "$output" >>"$TARGET_DIR/answers.env"
		else
			echo "Error: prompt.sh for profile '$profile' failed." >&2
			return 3
		fi
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

	# Remove profile from .dotfiles_profiles
	if [ -f "$profiles_file" ]; then
		grep -vxF "$profile" "$profiles_file" >"$profiles_file.tmp" && mv "$profiles_file.tmp" "$profiles_file"
	fi

	# Run uninstall script if it exists
	if [ -f "$DOTFILES_DIR/profiles/$profile/uninstall.sh" ]; then
		if ! sh "$DOTFILES_DIR/profiles/$profile/uninstall.sh"; then
			echo "Error: uninstall.sh for profile '$profile' failed." >&2
			return 2
		fi
	fi
}

build() {
	DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
	TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"

	clean

	# Sort profiles by dependencies using profiles.sh sort_dependencies
	sorted_profiles=""
	if [ -f "$TARGET_DIR/.dotfiles_profiles" ]; then
		profiles_input=$(tr '\n' ' ' <"$TARGET_DIR/.dotfiles_profiles")
		sorted_profiles=$(sh "$DOTFILES_DIR/scripts/profiles.sh" sort_dependencies "$profiles_input")
	fi

	if [ -n "$sorted_profiles" ]; then
		for p in $sorted_profiles; do
			if [ -n "$p" ]; then
				PROFILE_DIR="$DOTFILES_DIR/profiles/$p"
				# Copy install.sh
				profile_install="$PROFILE_DIR/install.sh"
				target_install="$TARGET_DIR/install.sh"
				if [ -f "$profile_install" ]; then
					if [ -f "$target_install" ]; then
						cat "$profile_install" >>"$target_install"
						# Add a blank line to ensure badly formatted scripts dont break
						echo "" >>"$target_install"
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
			fi
		done
	fi
}

clean() {
	# Copy existing files from target directory to $HOME before cleaning
	TARGET_HOME="$TARGET_DIR/home"
	if [ -d "$TARGET_HOME" ]; then
		find "$TARGET_HOME" -mindepth 1 | while read -r target_file; do
			rel_path="${target_file#"$TARGET_HOME"/}"
			home_file="$HOME/$rel_path"

			if [ -f "$target_file" ] && [ -f "$home_file" ]; then
				# If home_file is a symlink to target_file, remove it first
				if [ -L "$home_file" ] && [ "$(readlink "$home_file")" = "$target_file" ]; then
					rm "$home_file"
				fi
				cp "$target_file" "$home_file"
			fi
		done
	fi

	# Use git to remove tracked files except the ones we want to keep
	cd "$TARGET_DIR"
	git rm -rf --cached .
	git reset HEAD .dotfiles_profiles answers.env
	git reset HEAD .git
	git reset HEAD home/.ssh
	rm "$TARGET_DIR/install.sh"
	git add .
}

apply() {
	DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
	TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"
	TARGET_HOME="$TARGET_DIR/home"

	# Run install.sh from target dir if it exists
	if [ -f "$TARGET_DIR/install.sh" ]; then
		if [ -f "$TARGET_DIR/answers.env" ]; then
			# Source the answers before the script
			sh -c ". \"$TARGET_DIR/answers.env\"; . \"$TARGET_DIR/install.sh\""
		else
			sh "$TARGET_DIR/install.sh"
		fi
	fi

	# Recursively symlink files from target_dir/home into $HOME, create directories as needed
	find "$TARGET_HOME" -mindepth 1 | while read -r src; do
		rel_path="${src#"$TARGET_HOME"/}"
		dest="$HOME/$rel_path"

		if [ -d "$src" ]; then
			# If it's a directory, just create the directory in $HOME
			mkdir -p "$dest"
			continue
		fi

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

			# Check if files are identical by comparing their hashes
			if [ -f "$dest" ] && [ -f "$src" ]; then
				src_hash="$(sha256sum "$src" | cut -d' ' -f1)"
				dest_hash="$(sha256sum "$dest" | cut -d' ' -f1)"
				if [ "$src_hash" = "$dest_hash" ]; then
					echo "Files have identical contents, will replace with a symlink."
					rm -f "$dest"
				else
					printf "Delete and replace with symlink to '%s'? [y/N]: " "$src"
					read -r ans </dev/tty
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
			fi
		fi

		ln -s "$src" "$dest"
	done

	save
}

case "${1:-}" in
initialize)
	initialize
	;;
remove)
	remove
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
build)
	build
	;;
apply)
	apply
	;;
clean)
	clean
	;;
help)
	USAGE="Usage:
$(basename "$0") <command>

Available commands:
    initialize	Initializes the target directory for the first time if needed
	remove		Removes the target directory entirely
    save		Save the current state of the target directory as a commit
	discard		Discard uncommitted changes in the target directory
    install_profile	Marks a profile for installation into the target directory
	uninstall_profile	Unmarks/removes a profile from the target directory
	clean		Removes non-mandatory files from the target directory
	build		Builds the target directory contents based on selected profiles
	apply		Applies the target directory to the home directory
	help		Show this help message"

	printf "%s\n" "$USAGE"
	;;
*)
	# script was sourced, so we do nothing.
	;;
esac
