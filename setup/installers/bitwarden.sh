#!/bin/sh

install_bitwarden() {
    COMMAND="bitwarden"
    if check_command "$COMMAND"; then
        success "Command $COMMAND installed correctly"
        return 0
    else
        info "Installing $COMMAND"

        if is_linux; then
            install_bitwarden_linux
        elif is_macos; then
            install_bitwarden_macos
        else
            error "Unsupported operating system"
            exit 1
        fi
    fi
}

install_bitwarden_linux() {
    install_with_nix "bitwarden"

    if check_command "$COMMAND"; then
        success "Command $COMMAND installed correctly"
        return 0
    else
        error "Command $COMMAND was not installed correctly"
        exit 1
    fi
}

install_bitwarden_macos() {
    open "https://itunes.apple.com/app/bitwarden/id1352778147"
    warn "Press ENTER once installed and the setup will continue."
    read -r _dummy
}

install_bitwarden
