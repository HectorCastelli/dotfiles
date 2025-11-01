#!/usr/bin/env sh
set -eu

DOTFILES_DIR=${DOTFILES_DIR:-"$HOME/dotfiles"}
TARGET_DIR="${TARGET_DIR:-$DOTFILES_DIR/.target}"

echo "Writting to $TARGET_DIR/home/.gitconfig"

# Load brew optimizations
if [ -x "$TARGET_DIR/home/.config/shell/autoload/homebrew-env.sh" ]; then
	# shellcheck source=/dev/null
	. "$TARGET_DIR/home/.config/shell/autoload/homebrew-env.sh"
fi

# Setup git based on the user information provided by the profile
git config --file "$TARGET_DIR/home/.gitconfig" user.name "$USER_NAME"
git config --file "$TARGET_DIR/home/.gitconfig" user.email "$USER_EMAIL"

# Install flatpak for linux
if [ "$(uname)" = "Linux" ]; then
	# Fedora-based
	if command -v dnf >/dev/null 2>&1; then
		sudo dnf install -y flatpak
		flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	else
		echo "Error: This Linux system is not supported"
		exit 1
	fi
fi

# Install homebrew
# Must use bash for homebrew installation
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Load brew into the current shell session
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
if [ -x /opt/homebrew/bin/brew ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install zsh
brew install zsh
# Switch the user default shell to zsh
chsh -s "$(which zsh)"

# Install starship prompt
brew install starship

# Install basic utilities
if [ "$(uname)" = "Darwin" ]; then
	brew install coreutils # This ensures GNU utils like `ls`, `cat`, etc. are available on macOS
fi
brew install unzip

# Install monaspace font (patched with NerdFonts glyphs)
brew install --cask font-monaspace-nf

# Setup basic SSH identities
mkdir -p "$TARGET_DIR/home/.ssh"
# ed25519 keys for general use
if ! [ -e "$TARGET_DIR/home/.ssh/id_ed25519" ]; then
	ssh-keygen -t ed25519 -f "$TARGET_DIR/home/.ssh/id_ed25519" -N "" -C "$USER_EMAIL"
fi
# ed25519 keys for signatures
if ! [ -e "$TARGET_DIR/home/.ssh/id_ed25519_signing" ]; then
	ssh-keygen -t ed25519 -f "$TARGET_DIR/home/.ssh/id_ed25519_signing" -N "" -C "$USER_EMAIL"
	git config --file "$TARGET_DIR/home/.gitconfig" user.signingkey "$TARGET_DIR/home/.ssh/id_ed25519_signing"
	git config --file "$TARGET_DIR/home/.gitconfig" gpg.format "ssh"
fi

# Setup password manager
if [ "$(uname)" = "Linux" ]; then
	flatpak install -y flathub com.bitwarden.desktop
	flatpak install flathub com.belmoussaoui.Authenticator # TODO: find macos alternative
else
	brew install --cask bitwarden
fi
brew install bitwarden-cli

# Setup VSCode
brew install --cask visual-studio-code

# Setup cli utilities
cli_utils="bat jq yq viddy glow tlrc"
for util in $cli_utils; do
	brew install "$util"
done
