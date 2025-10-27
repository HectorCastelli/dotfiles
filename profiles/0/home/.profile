# prepend ~/.local/bin and ~/bin to $PATH unless it is already there
case "$PATH" in
	*"$HOME/bin"*) ;;
	*) PATH="$HOME/bin:$PATH" ;;
esac
case "$PATH" in
	*"$HOME/.local/bin"*) ;;
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
	PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
fi

# Update the PATH variable
export PATH
