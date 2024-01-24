#!/bin/sh

if command -v code >/dev/null 2>&1; then
    display_in_color "green" "code is already installed."
    exit 0
else
    display_in_color "yellow" "code is not installed."
    # Determine the operating system
    case "$(uname -s)" in
    Darwin)
        open https://code.visualstudio.com/sha/download?build=stable &
        os=darwin-universal
        echo "Press ENTER once installed and the setup will continue."
        read -r _dummy
        ;;
    Linux)
        nix-env --install --attr nixpkgs.vscode
        ;;
    *)
        display_in_color "red" "Unsupported operating system. Please install manually."
        exit 1
        ;;
    esac
fi
