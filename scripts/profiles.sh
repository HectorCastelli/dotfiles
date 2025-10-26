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

list_optional() {
	for d in "$PROFILES_DIR"/*; do
		[ -d "$d" ] || continue
		base=$(basename "$d")
		[ "$base" = "_template" ] && continue
		if [ ! -f "$d/.mandatory" ]; then
			printf '%s\n' "$base"
		fi
	done | sort
}

list() {
	# Print mandatory profiles first (sorted), then the rest (sorted)
	list_mandatory
	list_optional
}

run_prompt() {
	profile="${1:-}"
	if [ -z "$profile" ]; then
		printf 'Profile name required\n' >&2
		return 1
	fi

	d="$PROFILES_DIR/$profile"
	[ -d "$d" ] || {
		printf 'Profile "%s" not found\n' "$profile" >&2
		return 2
	}

	prompt="$d/prompt.sh"
	answers="$d/answers.env"
	[ -f "$prompt" ] || {
		printf 'No prompt.sh found for profile "%s"\n' "$profile" >&2
		return 0
	}

	# Load existing answers.env if present
	# shellcheck source=/dev/null
	if [ -f "$answers" ]; then
		. "$answers"
	fi

	# Run prompt.sh and save output to answers.env
	if output="$(sh "$prompt")"; then
		printf '%s\n' "$output" >"$answers"
	else
		printf 'Prompt for profile "%s" failed\n' "$profile" >&2
	fi
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
list_optional)
	list_optional
	;;
run_prompt)
	shift
	run_prompts "$@"
	;;
help)
	USAGE="Usage:
$(basename "$0") <command>

Available commands:
	create	Create a new profile
	list	List all profiles
	list_mandatory	List all mandatory profiles
	list_optional	List all optional profiles
	run_prompt	Run prompts for a profile and stores their answers
	help	Show this help message"

	printf "%s\n" "$USAGE"
	;;
*)
	# script was sourced, so we do nothing.
	;;
esac
