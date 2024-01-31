#!/bin/sh

install_app() {
    APP=$1
    . "./setup/intallers/$APP.sh"
}
