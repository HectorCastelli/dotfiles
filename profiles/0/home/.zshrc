#!/usr/bin/env zsh

# Load profile if it wasn't already
if [[ -z "$DOTFILES_ZPROFILE_LOADED" ]]; then
	source "$HOME/.zprofile"
fi

if [[ -z "$DOTFILES_PROFILE_LOADED" ]]; then
	function load_profile {
		emulate -L sh
		source "$HOME/.profile"
	}
	load_profile
fi

eval "$(starship init zsh)"
