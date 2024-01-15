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
    curl -L https://nixos.org/nix/install -o nix-install.sh
}

cleanup_nix() {
    rm nix-install.sh
}

install_linux() {
    download_nix
    sh nix-install.sh --daemon
    cleanup_nix
}

install_macos() {
    download_nix
    sh nix-install.sh
    cleanup_nix
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
            install_linux
            ;;
        *)
            echo "Unsupported operating system. Please install manually."
            exit 1
            ;;
    esac
}

main
