#!/bin/sh

if command -v espanso >/dev/null 2>&1; then
    display_in_color "green" "espanso is already installed."
    exit 0
else
    display_in_color "yellow" "espanso is not installed."
    # Determine the operating system
    case "$(uname -s)" in
    Darwin)
        nix-env --install --attr nixpkgs.espanso-wayland
        ;;
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
            display_in_color "red" "Unsupported session type: $session_type. Please install manually."
            exit 1
            ;;
        esac
        ;;
    *)
        display_in_color "red" "Unsupported operating system. Please install manually."
        exit 1
        ;;
    esac
fi
