#!/bin/sh

install_home() {
    info "Installing \$HOME files"

    if is_macos; then
        install_home_macos
    fi

    find "$(pwd)/home" -type f,l | while read -r file; do
        debug "Linking $file"
        target=$(get_relative_path "$file" "$(pwd)/home")
        target_dir=$(get_relative_path "$(dirname "$file")" "$(pwd)/home")
        if [ -e "$HOME/$target" ] && ! [ -h "$HOME/$target" ]; then
            warn "File already exists and is not a symbolic link"
            read -rp "Do you want to overwrite it? [y/N]" answer </dev/tty
            case $answer in
            [Yy]*)
                rm "$HOME/$target"
                ln -sf "$file" "$HOME/$target"
                ;;
            *)
                warn "Skipping file, but this may cause failures"
                ;;
            esac
        else
            mkdir -p "$HOME/$target_dir"
            ln -sf "$file" "$HOME/$target"
        fi
    done
    success "\$HOME files installed"
    return 0
}

install_home_macos() {
    debug "Installing on macOS"
    ln -sf "$(pwd)/home/.config/espanso" "$(pwd)/home/Library/Application Support/espanso"
    ln -sf "$(pwd)/home/.config/Code" "$(pwd)/home/Library/Application Support/Code"
    mkdir -p "$HOME/Library/Application Support"
}
