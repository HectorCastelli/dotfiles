#!/bin/sh

alias g='git'
alias ga='git add'
alias gb='git branch'
alias gbD='git branch --delete'
alias gco='git checkout'
alias gcor='git checkout --recurse-submodules'
alias gc='git commit --verbose'
alias gca='git commit --verbose --amend'
alias gcm='git commit --verbose --message'
alias gcnm='git commit --verbose --no-verify --message'
gcl() {
    git fetch --all
    info "Deleting local branches that no longer have a remote"
    git branch -vv | grep 'gone]' | awk '{print $1}' | xargs git branch -D
    info "Listing local branches that do not have a remote"
    git branch --no-merged | awk '{print $1}'
}
alias gf='git fetch'
alias glo='git log --oneline --decorate'
alias glo!='git log --graph'
alias gl='git pull'
alias glr='git pull --rebase'
alias gp='git push'
alias gpd='git push --dry-run'
alias gpf!='git push --force'
alias grm='git rm'
alias grmc='git rm --cached'
alias grv='git revert'
alias gst='git status'
