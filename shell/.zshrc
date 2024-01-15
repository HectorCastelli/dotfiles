# ~/.zshrc

export DOTFILES_DIR="$HOME/dotfiles"
export DOTFILES_SHELL="$HOME/dotfiles/shell"

source "$DOTFILES_SHELL/ssh-agent.sh"
source "$DOTFILES_SHELL/vscode.sh"

source "$DOTFILES_SHELL/aliases/git.sh"
source "$DOTFILES_SHELL/aliases/dotfiles.sh"

source "$DOTFILES_DIR/scripts/worklog.sh"

eval "$(starship init zsh)"
