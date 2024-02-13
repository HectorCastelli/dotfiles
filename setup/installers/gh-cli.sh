#!/bin/sh

install_gh_cli() {
    info "Setting up GitHub"
    gh auth login --hostname github.com --scopes admin:ssh_signing_key
    gh auth refresh --hostname github.com --scopes admin:public_key
    success "GitHub authenticated"

    info "Adding machine to GitHub"
    if [ -e "$HOME/.ssh/github_authentication" ]; then
        gh ssh-key add ~/.ssh/github_authentication.pub --title "$(hostname) authentication" --type authentication
        success "Setup authentication key"
    else
        error "ssh key github_authentication was not found"
    fi

    if [ -e "$HOME/.ssh/github_signing" ]; then
        gh ssh-key add ~/.ssh/github_signing.pub --title "$(hostname) signing" --type signing
        success "Setup signing key"
    else
        error "ssh key github_authentication was not found"
    fi

}

install_gh_cli
