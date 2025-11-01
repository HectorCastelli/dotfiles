#!/bin/sh

get_relative_path() {
	if [ "$#" -ne 2 ]; then
		echo "Usage: get_relative_path <file_path> <reference_dir>"
		return 1
	fi

	file_path="$1"
	reference_dir="$2"

	# Get the canonical absolute paths
	absolute_file_path=$(realpath "$file_path")
	absolute_reference_dir=$(realpath "$reference_dir")

	# Ensure the paths are valid
	if [ ! -e "$absolute_file_path" ]; then
		echo "Error: File not found: $file_path"
		return 1
	fi

	if [ ! -d "$absolute_reference_dir" ]; then
		echo "Error: Directory not found: $reference_dir"
		return 1
	fi

	# Use parameter expansion to get the relative path
	relative_path="${absolute_file_path#"$absolute_reference_dir"/}"

	echo "$relative_path"
}
