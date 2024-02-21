#!/bin/sh

# Load config file
export WORKLOG_CONFIG="$HOME/.config/worklog.json"

# Get worklog file
WORKLOG_FILE="$HOME/$(jq -r '.file' "$WORKLOG_CONFIG")"
export WORKLOG_FILE

# Fetch types from the JSON file
_worklog_extract_types() {
    jq -r '.types[]' "$WORKLOG_CONFIG"
}

# Define the log command with completion
worklog() {
    types=$(_worklog_extract_types)
    # If no arguments provided, show available types
    if [ $# -eq 0 ]; then
        echo "Error: Types are required: available types: $types"
        return 1
    fi

    _type="$1"

    shift # Shift to remove the first argument
    _message=""
    for arg in "$@"; do
        _message="$_message $arg"
    done

    _timestamp=$(date +%s)

    printf "%s\t%s\t%s\n" "$_timestamp" "$_type" "$_message" >>"$WORKLOG_FILE"
}
