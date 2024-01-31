#!/bin/zsh

case "$(uname -s)" in
Darwin)
    # See https://github.com/NixOS/nix/issues/956#issuecomment-1367457122
    if [ -d ~/.nix-profile/Applications ]; then
        cd ~/.nix-profile/Applications || exit 1

        for f in *.app; do
            info "Setting up $f."
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
    if [ -d "$HOME/.nix-profile/share" ] ; then
        # set PATH so it includes user's private bin if it exists
        XDG_DATA_DIRS=$HOME/.nix-profile/share:$XDG_DATA_DIRS
    fi
    if [ -d "/nix/var/nix/profiles/default/share" ] ; then
        # set PATH so it includes user's private bin if it exists
        XDG_DATA_DIRS=/nix/var/nix/profiles/default/share:$XDG_DATA_DIRS
    fi
    ;;
*)
    error "Unsupported operating system. Please install manually."
    exit 1
    ;;
esac
