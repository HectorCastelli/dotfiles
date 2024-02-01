#!/bin/sh

install_meetingbar() {
        info "Installing meetingbar"

        if is_macos; then
            open "https://apps.apple.com/us/app/id1532419400"
            warn "Press ENTER once installed and the setup will continue."
            read -r _dummy
        else
            error "Unsupported operating system"
        fi

}

install_meetingbar