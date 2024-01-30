#!/bin/sh

# shellcheck source=../shell/ansi_log.sh
. "$HOME/dotfiles/shell/ansi_log.sh"

info "Installing gh cli extensions"

info "installing gh-user-status"
gh extension install vilmibm/gh-user-status

info "installing gh-notify"
gh ext install meiji163/gh-notify