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

install_with_nix() {
    COMMAND=$1
    if [ -z "$2" ]; then
        CHECK_COMMAND="$1"
    else
        CHECK_COMMAND="$2"
    fi
    if check_command_nix "$CHECK_COMMAND"; then
        success "Command $COMMAND installed correctly"
        return 0
    else
        info "Installing $COMMAND"

        nix-env --install --attr "nixpkgs.$COMMAND"

        if check_command_nix "$CHECK_COMMAND"; then
            success "Command $COMMAND installed correctly"
            update_nix_desktop
            return 0
        else
            error "Command $COMMAND was not installed correctly"
            exit 1
        fi
    fi
}

update_nix_desktop() {
    if is_macos; then
        info "Updating desktop applications installed with nix"
        # See https://github.com/NixOS/nix/issues/956#issuecomment-1367457122
        if [ -d ~/.nix-profile/Applications ]; then
            cd ~/.nix-profile/Applications || exit 1

            for f in *.app; do
                info "Setting up $f."
                mkdir -p ~/Applications/
                rm -f "$HOME/Applications/$f"

                # Mac aliases don’t work on symlinks
                f="$(readlink -f "$f")"

                # Use Mac aliases because Spotlight doesn’t like symlinks
                osascript -e "tell app \"Finder\" to make new alias file at POSIX file \"$HOME/Applications\" to POSIX file \"$f\""
            done
        fi
    elif is_linux; then
        NIX_SHARE="$HOME/.nix-profile/share/applications/"
        LOCAL_SHARE="$HOME/.local/share/applications"
        find "$NIX_SHARE" -type f,l | while read -r file; do
            debug "Linking $file"
            target=$(basename "$file")
            if [ -e "$LOCAL_SHARE/$target" ]; then
                warn "File already exists"
            else
                mkdir -p "$LOCAL_SHARE"
                ln -sf "$file" "$LOCAL_SHARE/$target"
            fi
        done
    fi
}
