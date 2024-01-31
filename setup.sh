#!/bin/sh

. ./bin/ansi_log.sh
. ./bin/check_command.sh
. ./bin/detect_platform.sh
. ./bin/relative_path.sh
. ./bin/source_recursive.sh

info "Loading installers"

source_recursive "./setup/installers"

info "Running installers"

install_home
install_nix
install_zsh