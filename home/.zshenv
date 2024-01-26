# ~/.zshenv

# Global variables
export DOTFILES_DIR="$HOME/dotfiles"
export DOTFILES_SHELL="$HOME/dotfiles/shell"

# Nix configuration
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi
if [ "$(uname -s)" = "Linux" ]; then
   # Running on Linux
    if [ -d "$HOME/.nix-profile/share" ] ; then
        # set PATH so it includes user's private bin if it exists
        XDG_DATA_DIRS=$HOME/.nix-profile/share:$XDG_DATA_DIRS
    fi
    if [ -d "/nix/var/nix/profiles/default/share" ] ; then
        # set PATH so it includes user's private bin if it exists
        XDG_DATA_DIRS=/nix/var/nix/profiles/default/share:$XDG_DATA_DIRS
    fi
fi