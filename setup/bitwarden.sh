#!/bin/sh

if command -v bitwarden >/dev/null 2>&1; then
    display_in_color "green" "bitwarden is already installed."
    exit 0
else
    display_in_color "yellow" "bitwarden is not installed."
    # Determine the operating system
    case "$(uname -s)" in
    Darwin)
        open https://itunes.apple.com/app/bitwarden/id1352778147
        echo "Press ENTER once installed and the setup will continue."
        read -r _dummy
        ;;
    Linux)
        nix-env --install --attr nixpkgs.bitwarden
        ;;
    *)
        display_in_color "red" "Unsupported operating system. Please install manually."
        exit 1
        ;;
    esac
fi
