#!/bin/sh

# shellcheck source=../shell/ansi_log.sh
. "$HOME/dotfiles/shell/ansi_log.sh"

info "Installing espanso"

if command -v espanso >/dev/null 2>&1; then
    success "espanso is already installed."
    exit 0
else
    case "$(uname -s)" in
    Linux)
        nix-env --install --attr nixpkgs.espanso
        info "Starting up espanso service"
        espanso service register
        espanso start
        ;;
    *)
        error "Unsupported operating system. Please install manually."
        open "https://espanso.org/install/"
        warn "Press ENTER once installed and the setup will continue."
        read -r _dummy
        ;;
    esac
fi
