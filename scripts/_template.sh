#!/usr/bin/env sh
set -eu

function1() {
	echo "func1"
}

function2() {
	echo "func2"
}

case "${1:-}" in
function1)
	function1
	;;
function2)
	function2
	;;
help)
	USAGE="Usage:
$(basename "$0") <command>

Available commands:
    function1	Runs function1
    function2	Runs function2
	help	Show this help message"

	printf "%s\n" "$USAGE"
	;;
*)
	# script was sourced, so we do nothing.
	;;
esac
