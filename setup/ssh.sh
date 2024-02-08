#!/bin/sh

install_ssh() {
    info "Setting up SSH keys"

    email="hector.zacharias@gmail.com"

    if [ -e "$HOME/.ssh/github_authentication" ]; then
        success "Authentication key is already setup"
    else
        ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/github_authentication"
        gh ssh-key add ~/.ssh/github_authentication --title "$(hostname) authentication" --type authentication
        success "Setup authentication key"
    fi

    if [ -e "$HOME/.ssh/github_signing" ]; then
        success "Signing key is already setup"
    else
        ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/github_signing"
        gh ssh-key add ~/.ssh/github_signing --title "$(hostname) signing" --type signing
        success "Setup signing key"
    fi
}
