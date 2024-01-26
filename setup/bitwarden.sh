#!/bin/sh

# shellcheck source=../shell/ansi_log.sh
. "$HOME/dotfiles/shell/ansi_log.sh"

info "Installing bitwarden"

if command -v bitwarden >/dev/null 2>&1; then
    success "bitwarden is already installed."
    exit 0
else
    case "$(uname -s)" in
    Darwin)
        open "https://itunes.apple.com/app/bitwarden/id1352778147"
        warn "Press ENTER once installed and the setup will continue."
        read -r _dummy
        ;;
    Linux)
        nix-env --install --attr nixpkgs.bitwarden
        ;;
    *)
        error "Unsupported operating system. Please install manually."
        exit 1
        ;;
    esac
fi
