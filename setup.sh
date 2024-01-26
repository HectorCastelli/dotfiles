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
            warn "File already exists."
            read -rp "Do you want to overwrite it? [y/N]" answer </dev/tty
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
    success "Symbolic links created"
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
    success "zsh was installed succesfully"
}

setup_starship() {
    info "Setting up starship prompt"
    if command -v starship >/dev/null 2>&1; then
        success "starship is already installed"
    else
        # Install starship
        curl -sS https://starship.rs/install.sh | sh
    fi
    success "starship was installed succesfully"
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
    success "monaspace font was installed succesfully"
}

setup_applications() {
    info "Setting up applications (nixpkgs)"
    while IFS= read -r package; do
        info "Installing $package"
        nix-env --install --attr "nixpkgs.$package"
        success "$package was installed succesfully"
    done <"$HOME/dotfiles/setup/nixpkgs.list"

    info "Setting up other applications"
    for file in "$HOME/dotfiles/setup"/*.sh; do
        if [ -f "$file" ]; then
            info "Intalling from $file"
            . "$file"
            success "$file was installed succesfully"
        fi
    done

    if [ "$(uname -s)" = "Darwin" ]; then
        warn "Since you are running on MacOS, we need to setup links to the installed applications"
        . "$HOME/dotfiles/scripts/manual_run/setup-nix-desktop.sh"
    fi

}

main() {
    info "Setting up dotfiles"

    DOTFILES="$HOME/dotfiles"

    setup_links "$DOTFILES"

    setup_nix

    setup_shell

    setup_font

    setup_applications

    success "Switching to newly installed session"
    exec zsh
}

main
