#!/bin/sh

export GH="$HOME/github"
if [ ! -d "$GH" ]; then
    echo "Directory created: $GH"
    mkdir -p "$GH"
fi
