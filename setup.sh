#!/bin/sh

. ./bin/ansi_log.sh
. ./bin/check_command.sh
. ./bin/detect_platform.sh
. ./bin/relative_path.sh
. ./bin/source_recursive.sh

info "Loading installers"

source_recursive "./setup"

info "Pulling submodules"
git submodule update --init --recursive

info "Running installers"

install_home
install_nix
install_zsh

install_ssh

install_fonts

install_with_nix "bat"
install_with_nix "gh"
install_with_nix "glow"
install_with_nix "go"
install_with_nix "hyperfine"
install_with_nix "jq"
install_with_nix "lnav"
install_with_nix "tldr"
install_with_nix "vscode"
install_with_nix "yq"

install_with_go "semver" "maykonlf/semver-cli/cmd/semver@latest"
install_with_go "viddy" "sachaos/viddy@latest"
install_with_go "meteor" "stefanlogue/meteor@latest"

install_app "bitwarden"
install_app "espanso"
install_app "gh-cli"
install_app "gh-extensions"
install_app "meetingbar"

success "Everything was installed"
info "Please reboot your machine to ensure changes are loaded"
