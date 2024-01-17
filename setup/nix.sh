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

install_linux() {
    curl -L https://nixos.org/nix/install -o nix-install.sh
    # Has to be single-user due to https://github.com/NixOS/nix/issues/2374
    sh nix-install.sh --no-daemon
    rm nix-install.sh
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
            install_linux
            ;;
        *)
            echo "Unsupported operating system. Please install manually."
            exit 1
            ;;
    esac

    echo "Enabling nix"
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
}

main
