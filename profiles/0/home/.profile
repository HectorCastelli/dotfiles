#!/usr/bin/env sh

# prepend ~/.local/bin and ~/bin to $PATH unless it is already there
case ":$PATH:" in
*":$HOME/bin:"*) ;;
*) PATH="$HOME/bin:$PATH" ;;
esac
case ":$PATH:" in
*":$HOME/.local/bin:"*) ;;
*) PATH="$HOME/.local/bin:$PATH" ;;
esac

# Setup homebrew environment
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
if [ -x /opt/homebrew/bin/brew ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Add coreutils for macos systems to replace builtin utils
if [ "$(uname)" = "Darwin" ]; then
	PATH="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin:$PATH"
fi

# Add Home local bin to PATH
if [ -d "$HOME/.local/bin" ]; then
	PATH="$HOME/.local/bin:$PATH"
fi

# Load functions
find "$HOME/.config/shell/functions" -type f | while IFS= read -r functions_file; do
	# shellcheck source=/dev/null
	. "$functions_file"
done

# Execute autoload scripts
find "$HOME/.config/shell/autoload" -type f | while IFS= read -r autoload_file; do
	# shellcheck source=/dev/null
	. "$autoload_file"
done

# Update the PATH variable
export PATH

# Flag that the profile has been loaded
export DOTFILES_PROFILE_LOADED=1
