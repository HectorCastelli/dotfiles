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
	read -r ans </dev/tty
	case "$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')" in
	y | yes)
		touch "$target/.mandatory"
		printf 'Profile "%s" created and marked mandatory\n' "$name"
		;;
	*)
		printf 'Profile "%s" created\n' "$name"
		;;
	esac

	printf "Does this profile need any other profiles as prerequisites? (space separated, leave blank for none): "
	read -r prereqs </dev/tty
	prereqs=$(printf '%s' "$prereqs" | tr -d '\r\n' | tr -s ' ')
	if [ -n "$prereqs" ]; then
		# Split by space
		: >"$target/.needs"
		for p in $prereqs; do
			[ "$p" = "0" ] && continue # skip "0" since its always needed
			[ -n "$p" ] && printf '%s\n' "$p" >>"$target/.needs"
		done
	fi
}

sort_dependencies() {
	input_list="$1" # Space-separated list of profiles as input
	max_iterations="${2:-$(($(echo "$input_list" | wc -w) * 2))}"
	current_iteration="${3:-0}"

	# Break condition to avoid infinite recursion
	if [ "$current_iteration" -ge "$max_iterations" ]; then
		printf 'Error: Could not sort dependencies recursively after %d iterations (circular dependency detected)\n' "$max_iterations" >&2
		return 1
	fi

	output_list=""

	# Check if profile 0 exists in input and add it first
	case " $input_list " in
	*" 0 "*)
		output_list="0"
		;;
	esac

	# Process each profile in input list
	for profile in $input_list; do
		[ "$profile" = "0" ] && continue # already handled

		profile_dir="$PROFILES_DIR/$profile"
		needs_file="$profile_dir/.needs"

		if [ ! -f "$needs_file" ]; then
			# No dependencies, add to output if not already there
			case " $output_list " in
			*" $profile "*) ;;
			*)
				output_list="$output_list $profile"
				;;
			esac
		else
			# Process dependencies
			while IFS= read -r needed_profile; do
				[ -z "$needed_profile" ] && continue

				# Check if needed profile exists in input list
				case " $input_list " in
				*" $needed_profile "*)
					# Add needed profile to output if not already there
					case " $output_list " in
					*" $needed_profile "*) ;;
					*)
						output_list="$output_list $needed_profile"
						;;
					esac
					;;
				*)
					printf 'Error: Profile "%s" requires "%s" which is not in the input list\n' "$profile" "$needed_profile" >&2
					return 1
					;;
				esac
			done <"$needs_file"

			# Add current profile to output if not already there
			case " $output_list " in
			*" $profile "*) ;;
			*)
				output_list="$output_list $profile"
				;;
			esac
		fi
	done

	# Clean up leading space
	output_list="${output_list# }"

	# Check if input and output match (same profiles, potentially different order)
	if [ "$(echo "$input_list" | tr ' ' '\n' | tr '\n' ' ')" = "$(echo "$output_list" | tr ' ' '\n' | tr '\n' ' ')" ]; then
		printf '%s\n' "$output_list"
	else
		# Recursively call with output as new input
		sort_dependencies "$output_list" "$max_iterations" "$((current_iteration + 1))"
	fi
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
sort_dependencies)
	shift
	sort_dependencies "$*"
	;;
help)
	USAGE="Usage:
$(basename "$0") <command>

Available commands:
	create	Create a new profile
	list	List all profiles
	list_mandatory	List all mandatory profiles
	list_optional	List all optional profiles
	sort_dependencies	Sort a list of profiles by their dependencies
	help	Show this help message"

	printf "%s\n" "$USAGE"
	;;
*)
	# script was sourced, so we do nothing.
	;;
esac
