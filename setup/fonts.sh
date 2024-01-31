#!/bin/sh

install_fonts() {
    info "Installing fonts"

    install_fonts_monaspace

    success "Fonts installed correctly"
    return 0
}

install_fonts_monaspace() {
    debug "monaspace"
    if is_linux; then
        debug "Initializing user font directory"
        mkdir -p "$HOME/.local/share/fonts"
        sh -c "cd ./fonts/monaspace/util && chmod +x ./install_linux.sh && exec ./install_linux.sh"
    elif is_macos; then
        sh -c "cd ./fonts/monaspace/util && chmod +x ./install_macos.sh && exec ./install_macos.sh"
    else
        error "Unsupported operating system"
        exit 1
    fi
}
