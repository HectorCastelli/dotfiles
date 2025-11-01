#!/usr/bin/env sh
set -eu

DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"

brew install fnm

# Setup fnm autoload
mkdir -p "$TARGET_DIR/home/.config/shell/autoload"
fnm env --use-on-cd --shell=zsh >"$TARGET_DIR/home/.config/shell/autoload/fnm.sh"
chmod +x "$TARGET_DIR/home/.config/shell/autoload/fnm.sh"

# Load fnm in the current shell session
# shellcheck source=/dev/null
. "$TARGET_DIR/home/.config/shell/autoload/fnm.sh"

# Install and use latest LTS version of Node.js
fnm install --lts
fnm use lts-latest
