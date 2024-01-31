#!/bin/sh

check_command() {
    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            error "Command $cmd not found"
            return 1 # Command not found
        fi
    done
    return 0 # All commands found
}

check_command_nix() {
    for cmd in "$@"; do
        if ! nix-env -q "${cmd}" >/dev/null 2>&1; then
            error "Command $cmd not installed with nix"
            return 1 # Command not found with Nix
        fi
    done
    return 0 # All commands found with Nix
}
