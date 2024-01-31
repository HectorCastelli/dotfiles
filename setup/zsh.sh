#!/bin/sh

install_zsh() {
    COMMAND="zsh"
    if check_command "nix" "$COMMAND" && check_command_nix "$COMMAND"; then
        success "Command $COMMAND installed correctly"
        return 0
    else
        info "Installing $COMMAND"

        nix-env --install --attr nixpkgs.zsh

        if is_linux; then
            debug "Adding shell to list of login shells"
            command -v zsh | sudo tee -a /etc/shells
        fi

        debug "Changing default shell to zsh"
        chsh -s "$(command -v zsh)"

        install_starship

        if check_command "$COMMAND"; then
            success "Command $COMMAND installed correctly"
            return 0
        else
            error "Command $COMMAND was not installed correctly"
            exit 1
        fi
    fi
}

install_starship() {
    COMMAND="starship"
    if check_command "zsh" "$COMMAND"; then
        success "Command $COMMAND installed correctly"
        return 0
    else
        info "Installing $COMMAND"

        curl -sS https://starship.rs/install.sh | sh

        if check_command "$COMMAND"; then
            success "Command $COMMAND installed correctly"
            return 0
        else
            error "Command $COMMAND was not installed correctly"
            exit 1
        fi
    fi
}
