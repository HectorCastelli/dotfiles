#!/bin/zsh

# Load config file
export WORKLOG_CONFIG="$HOME/.config/worklog.json"

# Get worklog file
WORKLOG_FILE="$HOME/$(jq -r '.file' "$WORKLOG_CONFIG")"
export WORKLOG_FILE

# Fetch types from the JSON file
types=()
while IFS='' read -r line; do types+=("$line"); done < <(jq -r '.types[]' "$WORKLOG_CONFIG")

# Define the log command with completion
worklog() {
    # If no arguments provided, show available types
    if [[ $# -eq 0 ]]; then
        echo "Error: Types are required: available types: ${types[*]}"
        return 1
    fi

    local type="$1"
    local message="$2"
    local timestamp
    timestamp=$(date +%s)

    printf "%s\t%s\t%s" "$timestamp" "$type" "$message" >> "$WORKLOG_FILE"
}

# Define completion for the log command
_worklog() {
    _arguments '1: :->types' '2: :->message'
    case $state in
        types)
            _describe -t types 'type' "${types[@]}"
            ;;
        message)
            _default
            ;;
    esac
}

compdef _worklog worklog
