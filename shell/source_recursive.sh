#!/bin/sh

# Function to recursively source files from a specified directory
source_recursive() {
    dir="$1"

    # Check if the directory exists
    if [ -d "$dir" ]; then
        # Find and source all .sh files in the directory and its subdirectories
        for file in "$dir"/*.sh; do
            if [ -f "$file" ]; then
                # echo "Sourcing $file..."
                . "$file"
            fi
        done
    else
        echo "Directory $dir does not exist."
    fi
}
