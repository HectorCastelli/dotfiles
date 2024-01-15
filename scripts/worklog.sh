#!/bin/zsh

# Load config file
export WORKLOG_CONFIG="$HOME/.config/worklog.json"

# Get worklog file
WORKLOG_FILE="$HOME/$(jq -r '.file' "$WORKLOG_CONFIG")"
export WORKLOG_FILE

# Fetch types from the JSON file
extract_types() {
    jq -r '.types[]' "$WORKLOG_CONFIG"
}

# Define the log command with completion
worklog() {
    types=$(extract_types)
    # If no arguments provided, show available types
    if [[ $# -eq 0 ]]; then
        echo "Error: Types are required: available types: ${types[*]}"
        return 1
    fi

    local type="$1"
    local message=("${@:2}")
    local timestamp
    timestamp=$(date +%s)

    printf "%s\t%s\t%s\n" "$timestamp" "$type" "$message" >> "$WORKLOG_FILE"
}

# Define completion for the log command
_worklog() {
    local cur prev types
    cur="${words[CURSOR]}"
    prev="${words[PREV_CWORD]}"

    case "${prev}" in
        1)
            types=$(extract_types)
            _describe 'types' types
            return
            ;;
        *)
            _files
            return
            ;;
    esac
}

compdef _worklog worklog
