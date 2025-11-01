#!/bin/sh

is_linux() {
	[ "$(uname -s)" = "Linux" ]
}

is_macos() {
	[ "$(uname -s)" = "Darwin" ]
}

is_wayland() {
	is_linux && [ -n "$XDG_SESSION_TYPE" ] && [ "$XDG_SESSION_TYPE" = "wayland" ]
}

is_x11() {
	is_linux && [ -n "$XDG_SESSION_TYPE" ] && [ "$XDG_SESSION_TYPE" = "x11" ]
}
