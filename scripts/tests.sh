#!/usr/bin/env sh
set -eu

IMAGE_NAME="dotfiles-test"
REPO_DIR="$(git rev-parse --show-toplevel)"

CONTAINER_RUNTIME=""
detect_container_runtime() {
	if command -v podman >/dev/null 2>&1; then
		CONTAINER_RUNTIME="podman"
	elif command -v docker >/dev/null 2>&1; then
		CONTAINER_RUNTIME="docker"
	else
		printf "Error: Neither podman nor docker is installed\n" >&2
		exit 1
	fi
}
# Immediately invoke the function to set CONTAINER_RUNTIME to the correct value
detect_container_runtime

build() {
	"$CONTAINER_RUNTIME" build -t "$IMAGE_NAME" -f "$REPO_DIR/Containerfile" "$REPO_DIR"
}

launch() {
	"$CONTAINER_RUNTIME" run -it --rm --entrypoint /bin/sh \
		-v "$REPO_DIR":"/dotfiles":Z \
		"$IMAGE_NAME"
}

case "${1:-}" in
build)
	build
	;;
launch)
	launch
	;;
help)
	USAGE="Usage:
$(basename "$0") <command>

Available commands:
    build	Builds the test container
    launch	Launches the test container and drops into a shell
	help	Show this help message"

	printf "%s\n" "$USAGE"
	;;
*)
	# script was sourced, so we do nothing.
	;;
esac
