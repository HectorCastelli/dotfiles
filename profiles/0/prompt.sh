#!/usr/bin/env sh
set -u

if [ "${USER_NAME:-}" ]; then
	printf 'USER_NAME="%s"\n' "$USER_NAME"
else
	printf '%s' "what is your full name? " 1>&2
	read -r USER_NAME
	printf 'USER_NAME="%s"\n' "$USER_NAME"
fi

if [ "${USER_EMAIL:-}" ]; then
	printf 'USER_EMAIL="%s"\n' "$USER_EMAIL"
else
	printf '%s' "what is your email address? " 1>&2
	read -r USER_EMAIL
	printf 'USER_EMAIL="%s"\n' "$USER_EMAIL"
fi
