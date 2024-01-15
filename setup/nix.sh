#!/bin/sh

check() {
    if command -v nix >/dev/null 2>&1; then
        echo "nix is already installed."
        return 0
    else
        echo "nix is not installed."
        return 1
    fi
}

download_nix() {
}

cleanup_nix() {
    rm nix-install.sh
}

install_fedora() {
    sudo dnf install -y nix
}

install_macos() {
    curl -L https://nixos.org/nix/install -o nix-install.sh
    sh nix-install.sh
    rm nix-install.sh
}

main() {
    if check; then
        exit 0
    fi

    # Determine the operating system
    case "$(uname -s)" in
        Darwin)
            install_macos
            ;;
        Linux)
            # Check if it's Fedora
            if [ -e /etc/fedora-release ]; then
                install_fedora
            else
                echo "Unsupported Linux distribution. Please install manually."
                exit 1
            fi
            ;;
        *)
            echo "Unsupported operating system. Please install manually."
            exit 1
            ;;
    esac
}

main
