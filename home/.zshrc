#!/bin/zsh

# shellcheck source=shell/source_recursive.sh
. "$HOME/dotfiles/shell/source_recursive.sh"

# Helper scripts
source_recursive "$DOTFILES_DIR/shell"

# Aliases
source_recursive "$DOTFILES_DIR/shell/aliases"

# Custom scripts
source_recursive "$DOTFILES_DIR/scripts"

# ZSH Plugins
source "$DOTFILES_DIR/shell/plugins/almostontop/almostontop.plugin.zsh"
source "$DOTFILES_DIR/shell/plugins/zsh-alias-finder/zsh-alias-finder.plugin.zsh"
source "$DOTFILES_DIR/shell/plugins/zsh-bd/bd.plugin.zsh"

# Auto-completions
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select # Use arrow keys to complete
zstyle ':completion::complete:*' gain-privileges 1 # Complete even with sudo

# Prompt initialization
eval "$(starship init zsh)"
