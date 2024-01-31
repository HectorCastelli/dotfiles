#!/bin/sh

install_gh_extensions() {
    info "Installing gh cli extensions"

    debug "installing gh-user-status"
    gh extension install vilmibm/gh-user-status

    debug "installing gh-notify"
    gh ext install meiji163/gh-notify

}

install_gh_extensions
