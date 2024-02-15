#!/bin/sh

alias dot_edit="$EDITOR_NON_BLOCKING $DOTFILES_DIR"
alias dot_update="(cd $DOTFILES_DIR && git pull && sh setup.sh && echo 'Updated')"
