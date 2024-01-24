#!/bin/sh

# shellcheck source=../ansi.sh
. "$HOME/dotfiles/scripts/ansi.sh"

# Determine the operating system
case "$(uname -s)" in
Darwin)
    if [ -d ~/.nix-profile/Applications ]; then
        cd ~/.nix-profile/Applications || exit 1

        for f in *.app; do
            display_in_color "green" "Setting up $f."
            mkdir -p ~/Applications/
            rm -f "$HOME/Applications/$f"

            # Mac aliases don’t work on symlinks
            f="$(readlink -f "$f")"

            # Use Mac aliases because Spotlight doesn’t like symlinks
            osascript -e "tell app \"Finder\" to make new alias file at POSIX file \"$HOME/Applications\" to POSIX file \"$f\""
        done
    fi
    ;;
Linux)
    display_in_color "green" "No action required. ZSHENV file will take care of it."
    ;;
*)
    display_in_color "red" "Unsupported operating system. Please install manually."
    exit 1
    ;;
esac
