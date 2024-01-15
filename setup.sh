#!/bin/bash

install_zsh() {
    if command -v zsh &>/dev/null; then
        echo "Zsh is already installed."
        return 0
    else
        # Determine the operating system
        case "$(uname -s)" in
            Darwin)
                install_zsh_macos
                ;;
            Linux)
                # Check if it's Fedora
                if [ -e /etc/fedora-release ]; then
                    install_zsh_fedora
                else
                    echo "Unsupported Linux distribution. Please install Zsh manually."
                    exit 1
                fi
                ;;
            *)
                echo "Unsupported operating system. Please install Zsh manually."
                exit 1
                ;;
        esac
    fi
}

install_zsh_macos() {
    # TODO: Install with nix instead
    if command -v brew &>/dev/null; then
        echo "Installing Zsh using Homebrew..."
        brew install zsh
    else
        echo "Homebrew is not installed. Please install Homebrew first."
        exit 1
    fi
}

install_zsh_fedora() {
    if command -v dnf &>/dev/null; then
        echo "Installing Zsh using dnf..."
        sudo dnf install -y zsh
    else
        echo "dnf is not installed. Please install dnf first."
        exit 1
    fi
}

echo "Check ZSH installation"
install_zsh

echo "Fetching dotfiles"
git clone https://github.com/HectorCastelli/dotfiles "$HOME/dotfiles"
DOTFILES_DIR="$HOME/dotfiles"

echo "Setup file links"
ln -sf "$DOTFILES/.config" "$HOME/.config"

echo "Setup zsh"
ln -sf "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"

echo "Setup starship prompt"
curl -sS https://starship.rs/install.sh | sh

echo "Setup nix"
sh <(curl -L https://nixos.org/nix/install)
zsh "$DOTFILES_DIR/nix/global.sh"

# Setup git
ln -sf "$DOTFILES/.gitconfig" "$HOME/.gitconfig"

echo "Restarting shell..."
exec zsh
