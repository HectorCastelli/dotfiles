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
        session_type=$XDG_SESSION_TYPE

        case "$session_type" in
        x11)
            nix-env --install --attr nixpkgs.espanso
            ;;
        wayland)
            warn "Wayland support is experimental and not very reliable"
            nix-env --install --attr nixpkgs.espanso-wayland
            ;;
        *)
            echo "Unsupported session type: $session_type. Exiting."
            exit 1
            ;;
        esac

        info "Starting up espanso service"
        espanso service register
        espanso start

        if [ "$session_type" = "wayland" ]; then
            warn "Adding permissions to monitor inputs"
            sudo setcap "cap_dac_override+p" "$(readlink "$(which espanso)")"
        fi
        ;;
    *)
        error "Unsupported operating system. Please install manually."
        open "https://espanso.org/install/"
        warn "Press ENTER once installed and the setup will continue."
        read -r _dummy
        ;;
    esac
fi
