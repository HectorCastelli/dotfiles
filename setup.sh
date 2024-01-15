#!/bin/sh

copy_new_files() {
    source_dir="$1"
    target_dir="$2"

    # Ensure target directory exists
    mkdir -p "$target_dir"

    # Copy files from source to target without overwriting
    for file in "$source_dir"/*; do
        target_file="$target_dir/$(basename "$file")"
        
        # Check if the target file already exists
        if [ ! -e "$target_file" ]; then
            cp "$file" "$target_file"
        else
            echo "Skipping existing file: $(basename "$file")"
        fi
    done
}

fetch_repo() {
    dest="$HOME/dotfiles"
    git clone https://github.com/HectorCastelli/dotfiles "$dest"
    echo "$dest"
}

setup_links() {
    dotfiles="$1"

    ln -sf "$dotfiles/.config" "$HOME/.config"
    ln -sf "$dotfiles/shell/.zshrc" "$HOME/.zshrc"
    ln -sf "$dotfiles/.gitconfig" "$HOME/.gitconfig"
}

main() {
    DOTFILES=$(fetch_repo)
    copy_new_files "$HOME/.config" "$DOTFILES/.config"
    setup_links "$DOTFILES"

    sh "$DOTFILES/setup/nix.sh"
    sh "$DOTFILES/setup/zsh.sh"
    sh "$DOTFILES/setup/starship.sh"

    exec zsh
}

main