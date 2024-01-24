#!/bin/sh

# shellcheck source=scripts/ansi.sh
. "$HOME/dotfiles/scripts/ansi.sh"

copy_new_files() {
    source_dir="$1"
    target_dir="$2"

    display_in_color "yellow" "Copying files from $source_dir into $target_dir"

    # Ensure target directory exists
    mkdir -p "$target_dir"

    # Copy files from source to target without overwriting
    for file in "$source_dir"/*; do
        target_file="$target_dir/$(basename "$file")"

        # Check if the target file already exists
        if [ ! -e "$target_file" ]; then
            cp -r "$file" "$target_file"
        else
            echo "Skipping existing file: $(basename "$file")"
        fi
    done
}

setup_links() {
    dotfiles="$1"

    display_in_color "yellow" "Setting up symbolic links"

    rm -rf "$HOME/.config"
    ln -sf "$dotfiles/.config" "$HOME/.config"

    ln -sf "$dotfiles/shell/.zshrc" "$HOME/.zshrc"
    ln -sf "$dotfiles/shell/.zshenv" "$HOME/.zshenv"

    ln -sf "$dotfiles/home/.gitconfig" "$HOME/.gitconfig"
}

setup_nix() {
    if command -v nix >/dev/null 2>&1; then
        display_in_color "green" "nix is already installed"
    else
        display_in_color "yellow" "nix is not installed"
        # Determine the operating system
        case "$(uname -s)" in
        Darwin)
            curl -L https://nixos.org/nix/install -o nix-install.sh
            sh nix-install.sh
            rm nix-install.sh
            ;;
        Linux)
            curl -L https://nixos.org/nix/install -o nix-install.sh
            # Has to be single-user due to https://github.com/NixOS/nix/issues/2374
            sh nix-install.sh --no-daemon
            rm nix-install.sh
            ;;
        *)
            display_in_color "red" "Unsupported operating system. Please install manually."
            exit 1
            ;;
        esac

        display_in_color "yellow" "Enabling nix"
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
}

setup_zsh() {
    if command -v zsh >/dev/null 2>&1; then
        display_in_color "green" "zsh is already installed."
    else
        display_in_color "yellow" "zsh is not installed."
        # Determine the operating system
        case "$(uname -s)" in
        Darwin)
            nix-env --install --attr nixpkgs.zsh
            ;;
        Linux)
            # Check if it's Fedora
            if [ -e /etc/fedora-release ]; then
                sudo dnf install -y zsh
            else
                display_in_color "red" "Unsupported Linux distribution. Please install manually."
                exit 1
            fi
            ;;
        *)
            display_in_color "red" "Unsupported operating system. Please install manually."
            exit 1
            ;;
        esac

        # Change shell
        display_in_color "yellow" "Changing default shell..."
        chsh -s "$(command -v zsh)"
    fi
}

setup_starship() {
    if command -v starship >/dev/null 2>&1; then
        display_in_color "green" "starship is already installed."
    else
        display_in_color "yellow" "starship is not installed."
        # Install starship
        curl -sS https://starship.rs/install.sh | sh
    fi
}

setup_font() {
    display_in_color "yellow" "installing monaspace font"
    # Determine the operating system
    case "$(uname -s)" in
    Darwin)
        git clone https://github.com/githubnext/monaspace.git monaspace
        zsh ./monaspace/utils/install_macos.sh
        # rm -rf monaspace
        ;;
    Linux)
        git clone https://github.com/githubnext/monaspace.git monaspace
        zsh ./monaspace/utils/install_linux.sh
        # rm -rf monaspace
        ;;
    *)
        display_in_color "red" "Unsupported operating system. Please install manually."
        exit 1
        ;;
    esac
}

setup_applications() {
    dir="$HOME/dotfiles/setup"

    # Check if the directory exists
    if [ -d "$dir" ]; then
        # Find and source all .sh files in the directory and its subdirectories
        for file in "$dir"/*.sh; do
            if [ -f "$file" ]; then
                # echo "Sourcing $file..."
                . "$file"
            fi
        done
    else
        echo "Directory $dir does not exist."
    fi
}

main() {
    DOTFILES="$HOME/dotfiles"
    display_in_color green "Setting up dotfiles"

    copy_new_files "$HOME/.config" "$DOTFILES/.config"
    setup_links "$DOTFILES"

    setup_nix
    setup_zsh
    setup_font
    setup_starship

    zsh "$DOTFILES/nix/global.sh"
    setup_applications

    exec zsh
}

main
