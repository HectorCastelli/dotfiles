#!/usr/bin/env zsh

# Load profile
source "$HOME/.zprofile"

function load_profile {
	emulate -L sh
	source "$HOME/.profile"
}
load_profile

# History configuration
# Set the number of history entries to save to the history file
SAVEHIST=9000
# Set the number of history entries to keep in memory (should be larger than SAVEHIST)
HISTSIZE=9999

# Record timestamp of each command in history along with the command itself
setopt EXTENDED_HISTORY
# Save each command to history file immediately after execution instead of waiting for shell exit
setopt INC_APPEND_HISTORY
# Sound a beep when trying to access a non-existent history entry
setopt HIST_BEEP
# When history is full, remove duplicate entries first before removing older entries
setopt HIST_EXPIRE_DUPS_FIRST
# Don't show duplicate commands when searching through history
setopt HIST_FIND_NO_DUPS
# Don't save a command if it's identical to the previous command
setopt HIST_IGNORE_DUPS
# Don't save commands that start with a space character
setopt HIST_IGNORE_SPACE
# Don't save 'history' and 'fc' commands to history
setopt HIST_NO_STORE
# Remove extra whitespace from commands before saving to history
setopt HIST_REDUCE_BLANKS
# Save each command to history file immediately after execution instead of waiting for shell exit
setopt INC_APPEND_HISTORY

# History keybinds
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search   # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# Auto-completions
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select                 # Use arrow keys to complete
zstyle ':completion::complete:*' gain-privileges 1 # Complete even with sudo

# Setup pushd/popd helper
setopt autopushd
setopt pushdignoredups

# Load plugins
source "$HOME/.config/shell/plugins/alias-tips/alias-tips.plugin.zsh"
source "$HOME/.config/shell/plugins/almostontop/almostontop.plugin.zsh"
source "$HOME/.config/shell/plugins/zsh-bd/bd.zsh"

# Starship prompt
eval "$(starship init zsh)"
