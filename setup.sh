#!/bin/sh

# shellcheck source=shell/ansi_log.sh
. "$HOME/dotfiles/shell/ansi_log.sh"
# shellcheck source=shell/relative_path.sh
. "$HOME/dotfiles/shell/relative_path.sh"

setup_macos_links() {
    dotfiles="$1"

    if [ "$(uname -s)" = "Darwin" ]; then
        info "Linking to MacOS directories"
        info "Espanso"
        ln -sf "$dotfiles/home/.config/espanso" "$dotfiles/home/Library/Application Support/espanso"
        info "Code"
        ln -sf "$dotfiles/home/.config/Code" "$dotfiles/home/Library/Application Support/Code"
        success "MacOS symbolic link hacks created"
    fi
}

setup_links() {
    dotfiles="$1"
    dotfiles_home="$dotfiles/home"

    info "Setting up symbolic links"

    setup_macos_links "$dotfiles"

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
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

        info "Enabling nix"
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        if command -v nix >/dev/null 2>&1; then
            success "nix was enabled succesfully"
        else
            error "Unable to execute nix after enabling it. Please retry the installation script from a new terminal session."
            exit 1
        fi

        info "Adding nixpkgs channel"
        nix-channel --add https://nixos.org/channels/nixos-23.11 nixpkgs
        nix-channel --update
    fi
}

setup_shell() {
    setup_zsh
    setup_starship
}

setup_zsh() {
    info "Setting up shell"
    if command -v zsh >/dev/null 2>&1; then
        success "zsh is already installed"
    else
        nix-env --install --attr nixpkgs.zsh
    fi
    info "Changing default shell to zsh"
    command -v zsh | sudo tee -a /etc/shells
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

    info "Setting up applications (go packages)"
    while IFS=$(printf '\n') read -r package; do
        info "Installing $package"
        go install "github.com/$package"
        success "$package was installed succesfully"
    done <"$HOME/dotfiles/setup/go.list"

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

setup_identity() {
    info "Setting up machine identity"
    setup_gh
    setup_ssh
}

setup_gh() {
    info "Setting up GitHub"
    gh auth login
    success "GitHub authenticated"
}

setup_ssh() {
    info "Setting up SSH keys"

    email="hector.zacharias@gmail.com"

    ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/github_authentication
    gh ssh-key add ~/.ssh/github_authentication --title "$(hostname) authentication" --type authentication
    success "Setup authentication key"

    ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/github_signing
    gh ssh-key add ~/.ssh/github_signing --title "$(hostname) signing" --type signing
    success "Setup signing key"
}

main() {
    info "Setting up dotfiles"

    DOTFILES="$HOME/dotfiles"

    setup_links "$DOTFILES"

    setup_nix

    setup_shell

    setup_font

    setup_applications

    setup_identity

    success "Switching to newly installed session"
    exec zsh
}

main
