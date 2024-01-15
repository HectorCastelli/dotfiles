#!/bin/sh

check() {
    if command -v zsh >/dev/null 2>&1; then
        echo "Zsh is already installed."
        return 0
    else
        echo "Zsh is not installed."
        return 1
    fi
}

install_macos() {
    nix-env --install --attr nixpkgs.zsh
}

install_fedora() {
    sudo dnf install -y zsh
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

    # Change shell
    echo "Changing default shell..."
    chsh -s "$(which zsh)"
}

main
