#!/bin/sh

setup_applications() {
    info "Setting up applications (nixpkgs)"
    info "Setting up applications (go packages)"

    info "Setting up other applications"
    for file in "$HOME/dotfiles/setup"/*.sh; do
        if [ -f "$file" ]; then
            info "Intalling from $file"
            sh "$file"
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
    gh auth login --scopes admin:ssh_signing_key
    success "GitHub authenticated"
}

setup_ssh() {
    info "Setting up SSH keys"

    email="hector.zacharias@gmail.com"

    if [ -e "$HOME/.ssh/github_authentication" ]; then
        success "Authentication key is already setup"
    else
        ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/github_authentication"
        gh ssh-key add ~/.ssh/github_authentication --title "$(hostname) authentication" --type authentication
        success "Setup authentication key"
    fi

    if [ -e "$HOME/.ssh/github_authentication" ]; then
        success "Signing key is already setup"
    else
        ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/github_signing"
        gh ssh-key add ~/.ssh/github_signing --title "$(hostname) signing" --type signing
        success "Setup signing key"
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

    setup_identity

    success "Switching to newly installed session"
    exec zsh
}

main
