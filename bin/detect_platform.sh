#!/bin/sh

is_linux() {
    if [ "$(uname -s)" = "Linux" ]; then
        return 0 # true
    else
        return 1 # false
    fi
}

is_mac() {
    if [ "$(uname -s)" = "Darwin" ]; then
        return 0 # true
    else
        return 1 # false
    fi
}

is_wayland() {
    if is_linux && [ -n "$XDG_SESSION_TYPE" ] && [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        return 0 # true
    else
        return 1 # false
    fi
}

is_x11() {
    if is_linux && [ -n "$XDG_SESSION_TYPE" ] && [ "$XDG_SESSION_TYPE" = "x11" ]; then
        return 0 # true
    else
        return 1 # false
    fi
}

# Example usage:
if is_linux; then
    echo "Running on Linux"

    if is_wayland; then
        echo "Using Wayland display server"
    elif is_x11; then
        echo "Using X11 display server"
    else
        echo "Unknown display server"
    fi
fi

if is_mac; then
    echo "Running on macOS"
fi
