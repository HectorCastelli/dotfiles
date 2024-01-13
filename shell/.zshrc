# ~/.zshrc

export DOTFILES_DIR="$HOME/dotfiles"
export DOTFILES_SHELL="$DOTFILES_DIR/shell"

source "$DOTFILES_SHELL/ssh-agent.sh"
source "$DOTFILES_SHELL/vscode.sh"

source "$DOTFILES_SHELL/aliases/git.sh"
source "$DOTFILES_SHELL/aliases/dotfiles.sh"

eval "$(starship init zsh)"
