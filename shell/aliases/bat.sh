#!/bin/sh

# Use bat as the pager for `man` commands
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
alias cat='bat'
