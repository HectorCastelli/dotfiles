#!/bin/sh

if [ -z "$SSH_AUTH_SOCK" ] || [ -z "$(ssh-add -L 2>/dev/null)" ]; then
	eval "$(ssh-agent -s)"
fi
