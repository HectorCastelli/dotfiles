#!/bin/sh

install_fonts() {
    info "Installing fonts"

    install_fonts_monaspace
    
    success "Fonts installed correctly"
    return 0
}

install_fonts_monaspace() {
    debug "monaspace"
    git clone https://github.com/githubnext/monaspace.git
        if is_linux; then
            debug "Initializing user font directory"
            mkdir -p "$HOME/.local/share/fonts"
            sh -c 'cd "$HOME/dotfiles/fonts/monaspace/" && exec ./util/install_linux.sh'
        elif is_macos; then
            sh -c 'cd "$HOME/dotfiles/fonts/monaspace/" && exec ./util/install_macos.sh'
        else
            error "Unsupported operating system"
            exit 1
        fi
}