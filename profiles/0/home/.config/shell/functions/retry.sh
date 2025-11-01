#!/bin/bash

retry() {
	max=${MAX_RETRIES:-5}

	n=1
	while true; do
		if "$@"; then
			break
		else
			{
				if [[ $n -lt $max ]]; then
					((n++))
					echo "Command failed. Attempt $n of $max"
				else
					echo "The command has failed after $n attempts." >&2
					exit 1
				fi
			}
		fi
	done
}
