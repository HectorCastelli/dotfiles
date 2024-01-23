# ~/.zshrc

# Function to recursively source files from a specified directory
source_recursive() {
    local dir="$1"

    # Check if the directory exists
    if [ -d "$dir" ]; then
        # Find and source all .sh files in the directory and its subdirectories
        find "$dir" -type f -name '*.sh' -exec source {} \;
    else
        echo "Directory $dir does not exist."
    fi
}


# Global variables
export DOTFILES_DIR="$HOME/dotfiles"
export DOTFILES_SHELL="$HOME/dotfiles/shell"

# Helper scripts
source_recursive "$DOTFILES_DIR/shell"

# Aliases
source_recursive "$DOTFILES_DIR/aliases"

# Custom scripts
source_recursive "$DOTFILES_DIR/scripts"

# ZSH Plugins
source "$DOTFILES_DIR/shell/plugins/almostontop/almostontop.plugin.zsh"
source "$DOTFILES_DIR/shell/plugins/zsh-alias-finder/zsh-alias-finder.plugin.zsh"

# Nix configuration
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ];
then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh";
fi

# Prompt initialization
eval "$(starship init zsh)"