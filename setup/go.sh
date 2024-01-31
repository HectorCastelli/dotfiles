#!/bin/sh

install_with_go() {
    COMMAND=$1
    REPOSITORY=$2

    if check_command "go" "$COMMAND"; then
        success "Command $COMMAND installed correctly"
        return 0
    else
        info "Installing $COMMAND from $REPOSITORY"

        go install "github.com/$REPOSITORY"

        # TODO: Get this to work on first install
        # if check_command "$COMMAND"; then
        #     success "Command $COMMAND installed correctly"
        #     return 0
        # else
        #     error "Command $COMMAND was not installed correctly"
        #     exit 1
        # fi
    fi
}
