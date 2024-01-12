# shellcheck shell=bash
if [ -d "$DOTFILES_DIR/bash/aliases" ]; then
    for file in "$DOTFILES_DIR/bash/aliases"/*; do
        if [ -f "$file" ]; then
            source "$file"
        fi
    done
fi