#!/usr/bin/env sh
set -u

# This script is the base for any questions that a profile may ask during its installation.
# It should execute immediately when sourced.
# The script should write to stdout the answers to the questions in the format: KEY=VALUE

if [ "${ANSWER:-}" ]; then
	printf 'ANSWER=%s\n' "$ANSWER"
else
	printf '%s' "what is the color of the sky? " 1>&2
	read -r ANSWER
	printf 'ANSWER=%s\n' "$ANSWER"
fi
