#!/bin/sh

install_nix() {
    COMMAND="nix"
    if check_command "$COMMAND"; then
        success "Command $COMMAND installed correctly"
        return 0
    else
        info "Installing $COMMAND"

        debug "Downloading and running installer"        
        curl --proto '=https' --tlsv1.2 -sSf -Lo install_nix.sh https://install.determinate.systems/nix
        sh install_nix.sh install --no-confirm
        rm install_nix.sh

        debug "Enabling daemon"
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        
        debug "Installing package channel"
        nix-channel --add https://nixos.org/channels/nixos-23.11 nixpkgs
        nix-channel --update

        if check_command "$COMMAND"; then
            success "Command $COMMAND installed correctly"
            return 0
        else
            error "Command $COMMAND was not installed correctly"
            exit 1
        fi
    fi
}