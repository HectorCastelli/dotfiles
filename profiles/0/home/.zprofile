#!/usr/bin/env zsh

source "$HOME/.profile"

# Load shell aliases recursively
for alias_file in $(find "$HOME/.config/shell/aliases" -type f); do
	source "$alias_file"
done
