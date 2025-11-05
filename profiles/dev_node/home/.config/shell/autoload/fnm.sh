#!/usr/bin/env sh
# Detect shell and set appropriate shell parameter
if [ -n "${ZSH_VERSION:-}" ]; then
	SHELL_TYPE="zsh"
elif [ -n "${BASH_VERSION:-}" ]; then
	SHELL_TYPE="bash"
else
	SHELL_TYPE="bash" # fallback to bash
fi

eval "$(fnm env --use-on-cd --shell=$SHELL_TYPE)"
