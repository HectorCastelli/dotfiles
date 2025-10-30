#!/bin/sh

export EDITOR="code --wait"
export EDITOR_NON_BLOCKING="code --new-window"

# Automatically handle specific use-cases for vscode integrated terminal
if [ "$TERM_PROGRAM" = "vscode" ]; then
    export ALMOSONTOP='false'
fi
