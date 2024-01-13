#!/bin/zsh

echo "Fetching dotfiles"
git clone https://github.com/HectorCastelli/dotfiles "$HOME/dotfiles"
DOTFILES_DIR="$HOME/dotfiles"

echo "Setup zsh"
ln -sf "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"

echo "Setup starship prompt"
curl -sS https://starship.rs/install.sh | sh
ln -sf "$DOTFILES/.config" "$HOME/.config"

echo "Setup nix"
sh <(curl -L https://nixos.org/nix/install)
zsh "$DOTFILES_DIR/nix/global.sh"

# Setup git
ln -sf "$DOTFILES/.gitconfig" "$HOME/.gitconfig"

echo "Restarting shell..."
exec zsh
