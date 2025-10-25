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
*)
	# script was sourced, so we do nothing.
	;;
esac
