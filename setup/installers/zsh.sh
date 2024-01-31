#!/bin/sh

install_zsh() {
    COMMAND="zsh"
    if check_command "nix" "$COMMAND"; then
        success "Command $COMMAND installed correctly"
        return 0
    else
        info "Installing $COMMAND"

        if check_command "$COMMAND"; then
            success "Command $COMMAND installed correctly"
            return 0
        else
            error "Command $COMMAND was not installed correctly"
            exit 1
        fi
    fi
}