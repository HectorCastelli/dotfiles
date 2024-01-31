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
        _session="$XDG_SESSION_TYPE"
        case "$_session" in
        wayland)
            nix-env --install --attr nixpkgs.espanso-wayland
            ;;
        x11)
            nix-env --install --attr nixpkgs.espanso
            ;;
        *)
            error "Unsupported session type: $session_type. Please install manually."
            open "https://espanso.org/install/"
            warn "Press ENTER once installed and the setup will continue."
            read -r _dummy
            exit 1
            ;;
        esac
        info "Starting up espanso service"
        espanso service register
        espanso start
        ;;
    *)
        error "Unsupported operating system. Please install manually."
        open "https://espanso.org/install/"
        warn "Press ENTER once installed and the setup will continue."
        read -r _dummy
        exit 1
        ;;
    esac
fi

if [ "$(uname -s)" = "Darwin" ]; then
    info "Setting up configuration symlinks for MacOs"
    rm -rf "$HOME/Library/Application Support/espanso"
    ln -sf "$HOME/dotfiles/home/.config/espanso" "$HOME/Library/Application Support/espanso"
fi
