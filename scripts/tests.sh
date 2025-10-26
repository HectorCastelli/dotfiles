#!/usr/bin/env sh
set -eu

# Detect container runtime (prefer podman, fallback to docker)
if command -v podman >/dev/null 2>&1; then
	CONTAINER_RUNTIME="podman"
elif command -v docker >/dev/null 2>&1; then
	CONTAINER_RUNTIME="docker"
else
	printf "Error: Neither podman nor docker is installed\n" >&2
	exit 1
fi

# Global variables
IMAGE_NAME="dotfiles-test"
REPORT_FILE="${REPORT_FILE:-test_report.txt}"
REPO_DIR="$(git rev-parse --show-toplevel)"

# Build the test image
build_image() {
	printf "Building test image with %s...\n" "$CONTAINER_RUNTIME"
	"$CONTAINER_RUNTIME" build -t "$IMAGE_NAME" -f "$REPO_DIR/Containerfile" "$REPO_DIR"
}

# Run a single test case in its own container
# Usage: run_test_case <description> <command>
run_test_case() {
	description="$1"
	shift
	command="$*"

	# Start a container for this test
	container=$("$CONTAINER_RUNTIME" run -d \
		-v "$REPO_DIR:/dotfiles:Z" \
		"$IMAGE_NAME" \
		sleep infinity 2>&1)

	# Run the command in the container and capture output and exit code
	if output=$("$CONTAINER_RUNTIME" exec "$container" sh -c "$command" 2>&1); then
		exit_code=0
	else
		exit_code=$?
	fi

	# Clean up the container
	"$CONTAINER_RUNTIME" rm -f "$container" >/dev/null 2>&1 || true

	# Write results to report
	{
		printf "\n[TEST] %s\n" "$description"
		printf "Command: %s\n" "$command"

		if [ -n "$output" ]; then
			printf "Output:\n%s\n" "$output"
		fi

		if [ $exit_code -eq 0 ]; then
			printf "[PASS] %s\n" "$description"
		else
			printf "[FAIL] %s (exit code: %d)\n" "$description" "$exit_code"
		fi
	} >>"$REPORT_FILE"

	# Also print to stdout
	if [ $exit_code -eq 0 ]; then
		printf "[PASS] %s\n" "$description"
	else
		printf "[FAIL] %s (exit code: %d)\n" "$description" "$exit_code"
	fi

	return $exit_code
}

# Assert function: wrapper for run_test_case for compatibility
# Usage: assert <description> <command>
assert() {
	run_test_case "$@"
}

# Run common tests that apply to all profiles
run_common_tests() {
	profile_name="$1"
	profile_dir="$REPO_DIR/profiles/$profile_name"

	printf "\n--- Common Tests ---\n" | tee -a "$REPORT_FILE"

	# Test 1: Check for syntax errors in install script
	if [ -f "$profile_dir/install.sh" ]; then
		run_test_case "Install script has no syntax errors" \
			"sh -n /dotfiles/profiles/$profile_name/install.sh"
	fi

	# Test 2: Check for syntax errors in uninstall script
	if [ -f "$profile_dir/uninstall.sh" ]; then
		run_test_case "Uninstall script has no syntax errors" \
			"sh -n /dotfiles/profiles/$profile_name/uninstall.sh"
	fi

	# Test 3: Install script exits successfully
	if [ -f "$profile_dir/install.sh" ]; then
		run_test_case "Install script exits successfully" \
			"cd /dotfiles/profiles/$profile_name && sh install.sh"
	fi

	# Test 4: Install script is idempotent (runs twice successfully)
	if [ -f "$profile_dir/install.sh" ]; then
		run_test_case "Install script exits successfully on second run (idempotent)" \
			"cd /dotfiles/profiles/$profile_name && sh install.sh && sh install.sh"
	fi

	# Test 5: Uninstall script exits successfully
	if [ -f "$profile_dir/uninstall.sh" ]; then
		run_test_case "Uninstall script exits successfully" \
			"cd /dotfiles/profiles/$profile_name && sh uninstall.sh"
	fi

	# Test 6: Install then uninstall works
	if [ -f "$profile_dir/install.sh" ] && [ -f "$profile_dir/uninstall.sh" ]; then
		run_test_case "Uninstall script exits successfully after an install" \
			"cd /dotfiles/profiles/$profile_name && sh install.sh && sh uninstall.sh"
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

	{
		printf "\n========================================\n"
		printf "Testing profile: %s\n" "$profile_name"
		printf "========================================\n"
	} | tee -a "$REPORT_FILE"

	# Run common tests for all profiles
	run_common_tests "$profile_name"

	# Run profile-specific tests if they exist
	if [ -f "$profile_dir/tests.sh" ]; then
		printf "\n--- Profile-Specific Tests ---\n" | tee -a "$REPORT_FILE"
		# Source the profile's test file and run tests
		# shellcheck disable=SC1090
		. "$profile_dir/tests.sh"
	fi
}

# Main test runner
run_tests() {
	# Initialize report file
	printf "Test Report - %s\n" "$(date)" >"$REPORT_FILE"
	printf "========================================\n\n" >>"$REPORT_FILE"

	# Build the image
	build_image

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
run_tests)
	shift
	run_tests "$@"
	;;
help)
	USAGE="Usage:
$(basename "$0") <command>

Available commands:
	build_image	Build the test container image
	run_tests [profile]	Run tests for all profiles or a specific profile
	help	Show this help message"

	printf "%s\n" "$USAGE"
	;;
*)
	# Default action: run tests
	run_tests "$@"
	;;
esac
