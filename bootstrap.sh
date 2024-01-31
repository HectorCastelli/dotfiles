#!/bin/sh

# This script downloads and sets up the dotfiles repository

# Define repository URL
DOTFILES_REPO="https://github.com/HectorCastelli/dotfiles.git"

# Download the dotfiles repository
git clone "$DOTFILES_REPO" || {
    echo "Error: Unable to clone dotfiles repository. Exiting."
    exit 1
}

# Change to the dotfiles directory
cd dotfiles || {
    echo "Error: Unable to change to dotfiles directory. Exiting."
    exit 1
}

# Add bin directory to the PATH or source the scripts
if [ -d bin ]; then
    export PATH="$PATH:$(pwd)/bin"
else
    echo "Warning: 'bin' directory not found in dotfiles repository."
fi

# Run setup.sh
if [ -f setup.sh ]; then
    ./setup.sh
else
    echo "Error: 'setup.sh' not found in dotfiles repository. Exiting."
    exit 1
fi

echo "Dotfiles setup complete!"

echo "0" > setup.status
