# shellcheck shell=bash

# Getting a reference to the dotfiles repository
DOTFILES_DIR="$HOME/dotfiles"

# SSH Agent
source $DOTFILES_DIR/bash/ssh-agent.sh

#  Aliases
if [ -d "$DOTFILES_DIR/bash/aliases" ]; then
    for file in "$DOTFILES_DIR/bash/aliases"/*; do
        if [ -f "$file" ]; then
            source "$file"
        fi
    done
fi