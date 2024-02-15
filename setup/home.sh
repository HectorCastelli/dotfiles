#!/bin/sh

install_home() {
    info "Installing \$HOME files"

    if is_macos; then
        install_home_macos
    fi

    find "$(pwd)/home" -type f | while read -r file; do
        target=$(get_relative_path "$file" "$(pwd)/home")
        target_dir=$(get_relative_path "$(dirname "$file")" "$(pwd)/home")
        debug "Linking $file to $HOME/$target"
        if [ -e "$HOME/$target" ] && ! [ -h "$HOME/$target" ]; then
            warn "File already exists and is not a symbolic link"
            warn "Do you want to overwrite it? [y/N]"
            read -r answer </dev/tty
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

symbolic_link_recursively() {
    from=$1
    to=$2
    mkdir -p "$to"

    {
        find "$from" -type f &
        find "$from" -type l
    } | while read -r file; do
        target=$(get_relative_path "$file" "$from")
        target_dir=$(get_relative_path "$(dirname "$file")" "$from")
        debug "Linking $file to $HOME/$target"
        if [ -e "$HOME/$target" ] && ! [ -h "$HOME/$target" ]; then
            warn "File already exists and is not a symbolic link"
            warn "Do you want to overwrite it? [y/N]"
            read -r answer </dev/tty
            case $answer in
            [Yy]*)
                rm "$to/$target"
                ln -sf "$file" "$to/$target"
                ;;
            *)
                warn "Skipping file, but this may cause failures"
                ;;
            esac
        else
            mkdir -p "$to/$target_dir"
            ln -sf "$file" "$to/$target"
        fi
    done
}

install_home_macos() {
    debug "Installing on macOS"
    symbolic_link_recursively "$(pwd)/home/.config/espanso" "$HOME/Library/Application Support/espanso"
    symbolic_link_recursively "$(pwd)/home/.config/Code" "$HOME/Library/Application Support/Code"
    mkdir -p "$HOME/Library/Application Support"
}
