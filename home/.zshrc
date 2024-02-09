#!/bin/zsh

# Golang
export PATH="$PATH:$(go env GOROOT)/bin:$(go env GOPATH)/bin"

# shellcheck source=../bin/source_recursive.sh
. "$HOME/dotfiles/bin/source_recursive.sh"
source_recursive "$HOME/dotfiles/bin"

# Helper scripts
source_recursive "$DOTFILES_DIR/shell"

# Aliases
source_recursive "$DOTFILES_DIR/shell/aliases"

# ZSH Plugins
source "$DOTFILES_DIR/shell/plugins/almostontop/almostontop.plugin.zsh"
source "$DOTFILES_DIR/shell/plugins/zsh-alias-finder/zsh-alias-finder.plugin.zsh"
source "$DOTFILES_DIR/shell/plugins/zsh-bd/bd.plugin.zsh"

# History
export HISTFILE=~/.zsh_history
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
setopt INC_APPEND_HISTORY # Append to history immediately
setopt EXTENDED_HISTORY # Register timestamp of command
setopt HIST_FIND_NO_DUPS # Avoid duplication when looking up
setopt HIST_IGNORE_ALL_DUPS # Avoid writing duplicates
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# Auto-completions
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select # Use arrow keys to complete
zstyle ':completion::complete:*' gain-privileges 1 # Complete even with sudo

# Setup pushd/popd helper
setopt autopushd

# Prompt initialization
eval "$(starship init zsh)"
