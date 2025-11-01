#!/usr/bin/env sh
set -u

if [ "${USER_NAME:-}" ]; then
	printf 'USER_NAME="%s"\n' "$USER_NAME"
else
	# Try to get name from git config first
	GIT_USER_NAME=$(git config --global user.name 2>/dev/null || true)
	if [ "$GIT_USER_NAME" ]; then
		USER_NAME="$GIT_USER_NAME"
		printf 'USER_NAME="%s"\n' "$USER_NAME"
	else
		printf '%s' "what is your full name? " 1>&2
		read -r USER_NAME
		printf 'USER_NAME="%s"\n' "$USER_NAME"
	fi
fi

if [ "${USER_EMAIL:-}" ]; then
	printf 'USER_EMAIL="%s"\n' "$USER_EMAIL"
else
	# Try to get email from git config first
	GIT_USER_EMAIL=$(git config --global user.email 2>/dev/null || true)
	if [ "$GIT_USER_EMAIL" ]; then
		USER_EMAIL="$GIT_USER_EMAIL"
		printf 'USER_EMAIL="%s"\n' "$USER_EMAIL"
	else
		printf '%s' "what is your email address? " 1>&2
		read -r USER_EMAIL
		printf 'USER_EMAIL="%s"\n' "$USER_EMAIL"
	fi
fi
