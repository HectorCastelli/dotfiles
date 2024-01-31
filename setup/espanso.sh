#!/bin/sh

# shellcheck source=../shell/ansi_log.sh
. "$HOME/dotfiles/shell/ansi_log.sh"

info "Installing espanso"

if command -v espanso >/dev/null 2>&1; then
    success "espanso is already installed."
    exit 0
else
    open "https://espanso.org/install/"
    warn "Press ENTER once installed and the setup will continue."
    read -r _dummy

    if [ "$(uname -s)" = "Linux" ]; then
        info "Starting up espanso service"
        espanso service register
        espanso start
    fi
fi
