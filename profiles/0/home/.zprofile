#!/usr/bin/env zsh

# Source the .profile to inherit global setup
if [[ -f "$HOME/.profile" ]]; then
	function load_profile {
		emulate -L sh
		source "$HOME/.profile"
	}
	load_profile
fi

# Load shell aliases recursively
for alias_file in $(find "$HOME/.config/shell/aliases" -type f -o -type l); do
	source "$alias_file"
done

# Flag that the zprofile has been loaded
export DOTFILES_ZPROFILE_LOADED=1
