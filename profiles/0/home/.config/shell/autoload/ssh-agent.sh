#!/bin/sh

if [ -z "$SSH_AUTH_SOCK" ] || [ -z "$(ssh-add -L 2>/dev/null)" ]; then
    eval "$(ssh-agent -s)"
    # else
    # echo "SSH agent is already running with the following keys:"
    # ssh-add -L
fi
