#!/usr/bin/env sh
set -eu

# Global variables
IMAGE_NAME="docker.io/fedora:latest"
REPORT_FILE="${REPORT_FILE:-test_report.txt}"
CURRENT_CONTAINER=""
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Build the test image (optional - we can use base fedora image directly)
build_image() {
	printf "Building test image...\n"
	if podman build -t "dotfiles-test" -f "$REPO_DIR/Containerfile" "$REPO_DIR"; then
		IMAGE_NAME="dotfiles-test"
		printf "Successfully built custom test image\n"
	else
		printf "Failed to build custom image, will use base fedora image\n"
		IMAGE_NAME="docker.io/fedora:latest"
	fi
}

# Start a new test container
start_container() {
	CURRENT_CONTAINER=$(podman run -d \
		-v "$REPO_DIR:/dotfiles:ro" \
		"$IMAGE_NAME" \
		sleep infinity)
	printf "Started container: %s\n" "$CURRENT_CONTAINER"
}

# Stop and remove the current container
cleanup_container() {
	if [ -n "$CURRENT_CONTAINER" ]; then
		printf "Cleaning up container: %s\n" "$CURRENT_CONTAINER"
		podman rm -f "$CURRENT_CONTAINER" >/dev/null 2>&1 || true
		CURRENT_CONTAINER=""
	fi
}

# Assert function: run a command in the container and report the result
# Usage: assert <description> <command>
assert() {
	description="$1"
	shift
	command="$*"
	
	printf "\n[TEST] %s\n" "$description" | tee -a "$REPORT_FILE"
	printf "Command: %s\n" "$command" | tee -a "$REPORT_FILE"
	
	# Run the command in the container and capture output and exit code
	if output=$(podman exec "$CURRENT_CONTAINER" sh -c "$command" 2>&1); then
		exit_code=0
	else
		exit_code=$?
	fi
	
	# Write output to report
	if [ -n "$output" ]; then
		printf "Output:\n%s\n" "$output" | tee -a "$REPORT_FILE"
	fi
	
	# Check result and write to report
	if [ $exit_code -eq 0 ]; then
		printf "[PASS] %s\n" "$description" | tee -a "$REPORT_FILE"
		return 0
	else
		printf "[FAIL] %s (exit code: %d)\n" "$description" "$exit_code" | tee -a "$REPORT_FILE"
		return 1
	fi
}

# Run tests for a specific profile
run_profile_tests() {
	profile_name="$1"
	profile_dir="$REPO_DIR/profiles/$profile_name"
	
	if [ ! -d "$profile_dir" ]; then
		printf "Profile '%s' not found\n" "$profile_name" >&2
		return 1
	fi
	
	if [ ! -f "$profile_dir/tests.sh" ]; then
		printf "No tests.sh found for profile '%s', skipping\n" "$profile_name"
		return 0
	fi
	
	printf "\n========================================\n" | tee -a "$REPORT_FILE"
	printf "Testing profile: %s\n" "$profile_name" | tee -a "$REPORT_FILE"
	printf "========================================\n" | tee -a "$REPORT_FILE"
	
	# Start a fresh container for this profile
	start_container
	
	# Source the profile's test file and run tests
	# shellcheck disable=SC1090
	. "$profile_dir/tests.sh"
	
	# Clean up after tests
	cleanup_container
}

# Main test runner
run_tests() {
	# Initialize report file
	printf "Test Report - %s\n" "$(date)" > "$REPORT_FILE"
	printf "========================================\n\n" >> "$REPORT_FILE"
	
	# Try to build the image, but don't fail if it doesn't work
	build_image || printf "Continuing with base image...\n"
	
	if [ $# -eq 0 ]; then
		# Run tests for all profiles
		for profile_dir in "$REPO_DIR/profiles"/*; do
			if [ -d "$profile_dir" ]; then
				profile_name=$(basename "$profile_dir")
				# Skip template
				if [ "$profile_name" = "_template" ]; then
					continue
				fi
				run_profile_tests "$profile_name"
			fi
		done
	else
		# Run tests for specified profile
		run_profile_tests "$1"
	fi
	
	printf "\n========================================\n" | tee -a "$REPORT_FILE"
	printf "Test run complete. Report saved to: %s\n" "$REPORT_FILE"
	printf "========================================\n"
}

case "${1:-}" in
build_image)
	build_image
	;;
start_container)
	start_container
	;;
cleanup_container)
	cleanup_container
	;;
run_tests)
	shift
	run_tests "$@"
	;;
help)
	USAGE="Usage:
$(basename "$0") <command>

Available commands:
	build_image	Build the test container image
	start_container	Start a test container
	cleanup_container	Clean up the current container
	run_tests [profile]	Run tests for all profiles or a specific profile
	help	Show this help message"

	printf "%s\n" "$USAGE"
	;;
*)
	# Default action: run tests
	run_tests "$@"
	;;
esac
