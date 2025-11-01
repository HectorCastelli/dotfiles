#!/bin/sh

find_in_parent() {
	filename=$1
	directory=${2:-$(pwd)}

	echo "Looking for $filename in $directory"

	if [ -e "$directory/$filename" ]; then
		parent="${directory%/*}"
		if [ "$parent" = "$directory" ]; then
			error "File $filename not found"
			return 1
		fi
		find_in_parent "$filename" "$parent"
	else
		echo "$directory/$filename"
	fi
}
