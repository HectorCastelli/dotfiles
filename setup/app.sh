#!/bin/sh

install_app() {
    APP=$1
    . "./setup/installers/$APP.sh"
}
