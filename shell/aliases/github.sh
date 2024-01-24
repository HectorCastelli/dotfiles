#!/bin/sh

create_if_not_exists() {
    _dir=$1
    if [ ! -d "$_dir" ]; then
        echo "Directory created: $_dir"
        mkdir -p "$_dir"
    fi
}

export GH="$HOME/github"
create_if_not_exists $GH

export GHPD6="$GH/powerd6"
create_if_not_exists $GHPD6

alias cdgh='cd $GH'
