#!/bin/sh

install_home() {
    info "Installing \$HOME files"

    if is_macos; then
        install_home_macos
    fi

    find "$(pwd)/home" -type f | while read -r file; do
        info "Linking $file"
        target=$(get_relative_path "$file" "$(pwd)/home")
        target_dir=$(get_relative_path "$(dirname "$file")" "$(pwd)/home")
        if [ -e "$HOME/$target" ]; then
            warn "File already exists."
            read -rp "Do you want to overwrite it? [y/N]" answer </dev/tty
            case $answer in
            [Yy]*)
                rm "$HOME/$target"
                ln -sf "$file" "$HOME/$target"
                ;;
            *)
                warn "Skipping file. This may cause failures."
                ;;
            esac
        else
            mkdir -p "$HOME/$target_dir"
            ln -sf "$file" "$HOME/$target"
        fi
    done
    if check_command "$COMMAND"; then
        success "Command $COMMAND installed correctly"
        return 0
    else
        error "Command $COMMAND was not installed correctly"
        exit 1
    fi
}

install_home_macos() {
    debug "Installing on macOS"
    ln -sf "$(pwd)/home/.config/espanso" "$(pwd)/home/Library/Application Support/espanso"
    ln -sf "$(pwd)/home/.config/Code" "$(pwd)/home/Library/Application Support/Code"
}
