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

# Auto-completions
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select # Use arrow keys to complete
zstyle ':completion::complete:*' gain-privileges 1 # Complete even with sudo

# Setup pushd/popd helper
setopt autopushd

# Prompt initialization
eval "$(starship init zsh)"
