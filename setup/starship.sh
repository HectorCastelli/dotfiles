#!/bin/sh

check() {
    if command -v starship >/dev/null 2>&1; then
        echo "starship is already installed."
        return 0
    else
        echo "starship is not installed."
        return 1
    fi
}

main() {
    if check; then
        exit 0
    fi

    curl -sS https://starship.rs/install.sh | sh
}

main
