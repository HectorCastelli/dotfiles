#!/usr/bin/env sh
set -eu

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
PROFILES_DIR="$DOTFILES_DIR/profiles"

create() {
	printf "Profile name: "
	if ! IFS= read -r name; then
		printf 'Failed to read profile name\n' >&2
		exit 1
	fi
	# sanitize
	name=$(printf '%s' "$name" | tr -d '\r\n')
	if [ -z "$name" ]; then
		printf 'No profile name provided\n' >&2
		exit 1
	fi

	target="$PROFILES_DIR/$name"
	if [ -e "$target" ]; then
		printf 'Profile "%s" already exists\n' "$name" >&2
		exit 1
	fi

	if [ ! -d "$PROFILES_DIR/_template" ]; then
		printf 'Template profile not found at %s/_template\n' "$PROFILES_DIR" >&2
		exit 1
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

list() {
	mandatory_names=""
	nonmandatory_names=""

	for d in "$PROFILES_DIR"/*; do
		[ -d "$d" ] || continue
		base=$(basename "$d")
		[ "$base" = "_template" ] && continue
		if [ -f "$d/.mandatory" ]; then
			mandatory_names="${mandatory_names}${base}\n"
		else
			nonmandatory_names="${nonmandatory_names}${base}\n"
		fi
	done

	# Print mandatory profiles first (sorted), then the rest (sorted)
	if [ -n "$mandatory_names" ]; then
		printf '%b' "$mandatory_names" | sort | sed 's/$/ */'
	fi

	if [ -n "$nonmandatory_names" ]; then
		printf '%b' "$nonmandatory_names" | sort
	fi
}

case "${1:-}" in
create)
	create
	;;
list)
	list
	;;
help)
	USAGE="Usage:
$(basename "$0") <command>

Available commands:
	create	Create a new profile
	list	List all profiles
	help	Show this help message"

	printf "%s\n" "$USAGE"
	;;
*)
	# script was sourced, so we do nothing.
	;;
esac
