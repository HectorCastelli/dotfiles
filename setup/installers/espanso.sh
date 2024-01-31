#!/bin/sh

install_espanso() {
    COMMAND="espanso"
    if check_command "$COMMAND"; then
        success "Command $COMMAND installed correctly"
        return 0
    else
        info "Installing $COMMAND"

        if is_linux; then
            install_linux
        elif is_macos; then
            install_macos
        else
            error "Unsupported operating system"
            exit 1
        fi
    fi
}

install_espanso_linux() {
    if is_wayland; then
        warn "Wayland support is experimental and not very reliable"
        install_with_nix "espanso-wayland"

        debug "Adding permissions to monitor inputs"
        sudo setcap "cap_dac_override+p" "$(readlink "$(which espanso)")"
    elif is_x11; then
        install_with_nix "espanso"
    else
        error "Unsupported session type"
        exit 1
    fi
    
    debug "Starting up espanso service"
    espanso service register
    espanso start


        if check_command "$COMMAND"; then
            success "Command $COMMAND installed correctly"
            return 0
        else
            error "Command $COMMAND was not installed correctly"
            exit 1
        fi
}

install_espanso_macos() {
    open "https://espanso.org/install/"
    warn "Press ENTER once installed and the setup will continue."
    read -r _dummy
}

install_espanso