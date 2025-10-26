#!/usr/bin/env sh
set -eu

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
PROFILES_DIR="$DOTFILES_DIR/profiles"

create() {
	printf "Profile name: "
	if ! IFS= read -r name; then
		printf 'Failed to read profile name\n' >&2
		return 1
	fi
	# sanitize
	name=$(printf '%s' "$name" | tr -d '\r\n')
	if [ -z "$name" ]; then
		printf 'No profile name provided\n' >&2
		return 2
	fi

	target="$PROFILES_DIR/$name"
	if [ -e "$target" ]; then
		printf 'Profile "%s" already exists\n' "$name" >&2
		return 3
	fi

	if [ ! -d "$PROFILES_DIR/_template" ]; then
		printf 'Template profile not found at %s/_template\n' "$PROFILES_DIR" >&2
		return 4
	fi

	cp -R "$PROFILES_DIR/_template" "$target"

	printf "Make profile mandatory? [y/N]: "
	if ! IFS= read -r ans; then
		ans=""
	fi
	case "$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')" in
	y | yes)
		touch "$target/.mandatory"
		printf 'Profile "%s" created and marked mandatory\n' "$name"
		;;
	*)
		printf 'Profile "%s" created\n' "$name"
		;;
	esac
}

list_mandatory() {
	for d in "$PROFILES_DIR"/*; do
		[ -d "$d" ] || continue
		base=$(basename "$d")
		[ "$base" = "_template" ] && continue
		if [ -f "$d/.mandatory" ]; then
			printf '%s\n' "$base"
		fi
	done | sort
}

list() {
	# Print mandatory profiles first (sorted), then the rest (sorted)
	list_mandatory

	for d in "$PROFILES_DIR"/*; do
		[ -d "$d" ] || continue
		base=$(basename "$d")
		[ "$base" = "_template" ] && continue
		if [ ! -f "$d/.mandatory" ]; then
			printf '%s\n' "$base"
		fi
	done | sort
}

case "${1:-}" in
create)
	create
	;;
list)
	list
	;;
list_mandatory)
	list_mandatory
	;;
help)
	USAGE="Usage:
$(basename "$0") <command>

Available commands:
	create	Create a new profile
	list	List all profiles
	list_mandatory	List all mandatory profiles
	help	Show this help message"

	printf "%s\n" "$USAGE"
	;;
*)
	# script was sourced, so we do nothing.
	;;
esac
