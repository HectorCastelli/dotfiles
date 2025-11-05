#!/usr/bin/env sh

export EDITOR="code --wait"
export EDITOR_NON_BLOCKING="code --new-window"

# Automatically handle specific use-cases for vscode integrated terminal
if [ "$TERM_PROGRAM" = "vscode" ]; then
	# Keep the usual behavior for command finalization
	export ALMOSONTOP='false'
	# Load VSCode shell integration for zsh
	#shellcheck source=/dev/null
	. "$(code --locate-shell-integration-path zsh)"
fi
