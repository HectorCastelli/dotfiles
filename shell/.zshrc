# ~/.zshrc

export DOTFILES_DIR="$HOME/dotfiles"
export DOTFILES_SHELL="$HOME/dotfiles/shell"

source "$DOTFILES_SHELL/ssh-agent.sh"
source "$DOTFILES_SHELL/vscode.sh"

source "$DOTFILES_SHELL/aliases/git.sh"
source "$DOTFILES_SHELL/aliases/dotfiles.sh"

source "$DOTFILES_DIR/scripts/worklog.sh"

source "$DOTFILES_DIR/shell/plugins/almostontop/almostontop.plugin.zsh"
source "$DOTFILES_DIR/shell/plugins/zsh-alias-finder/zsh-alias-finder.plugin.zsh"

if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ];
then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh";
fi

eval "$(starship init zsh)"