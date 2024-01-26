#!/bin/sh

# shellcheck source=shell/ansi_log.sh
. "$HOME/dotfiles/shell/ansi_log.sh"
# shellcheck source=shell/relative_path.sh
. "$HOME/dotfiles/shell/relative_path.sh"

setup_links() {
    dotfiles="$1"
    dotfiles_home="$dotfiles/home"

    info "Setting up symbolic links"

    find "$dotfiles_home" -type f | while read -r file; do
        info "Linking $file"
        target=$(get_relative_path "$file" "$dotfiles_home")
        target_dir=$(get_relative_path "$(dirname "$file")" "$dotfiles_home")
        if [ -e "$HOME/$target" ]; then
            warn "File already exists. Do you want to overwrite it? (y/N)"
            read -r answer
            case $answer in
            [Yy]*)
                rm "$HOME/$target"
                ln -sf "$file" "$HOME/$target"
                ;;
            *)
                warn "Skipping file. This may cause failures."
                ;;
            esac
        else
            mkdir -p "$HOME/$target_dir"
            ln -sf "$file" "$HOME/$target"
        fi
    done
}

setup_nix() {
    info "Setting up nix"
    if command -v nix >/dev/null 2>&1; then
        success "nix is already installed"
    else
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
            error "Unsupported operating system. Please install manually."
            exit 1
            ;;
        esac

        info "Enabling nix"
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        if command -v nix >/dev/null 2>&1; then
            success "nix was enabled succesfully"
        else
            error "Unable to execute nix after enabling it. Please retry the installation script from a new terminal session."
            exit 1
        fi
    fi
}

setup_shell() {
    setup_zsh
    setup_starship
}

setup_zsh() {
    # TODO: This is a hack to ensure nix is available at this step... it should not be needed
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"

    info "Setting up shell"
    if command -v zsh >/dev/null 2>&1; then
        success "zsh is already installed"
    else
        nix-env --install --attr nixpkgs.zsh
    fi
    info "Changing default shell to zsh"
    chsh -s "$(command -v zsh)"
}

setup_starship() {
    info "Setting up starship prompt"
    if command -v starship >/dev/null 2>&1; then
        success "starship is already installed"
    else
        # Install starship
        curl -sS https://starship.rs/install.sh | sh
    fi
}

setup_font() {    
    info "Installing monaspace font"
    case "$(uname -s)" in
    Darwin)
        sh -c 'cd "$HOME/dotfiles/fonts/monaspace/" && exec ./util/install_macos.sh'
        ;;
    Linux)
        mkdir -p "$HOME/.local/share/fonts"
        sh -c 'cd "$HOME/dotfiles/fonts/monaspace/" && exec ./util/install_linux.sh'
        ;;
    *)
        error "Unsupported operating system. Please install manually"
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
                sh "$file"
            fi
        done
    else
        echo "Directory $dir does not exist."
    fi
}

main() {
    info "Setting up dotfiles"

    DOTFILES="$HOME/dotfiles"

    setup_links "$DOTFILES"

    setup_nix

    setup_shell

    setup_font

    # zsh "$DOTFILES/nix/global.sh"
    # setup_applications

    # exec zsh
}

main
