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
PROFILE_TEST_CONTAINER=""  # Container for profile-specific tests

# Build the test image
build_image() {
	printf "Building test image with %s...\n" "$CONTAINER_RUNTIME"
	"$CONTAINER_RUNTIME" build -t "$IMAGE_NAME" -f "$REPO_DIR/Containerfile" "$REPO_DIR"
}

# Run a test case (optionally in an existing container)
# Usage: run_test_case <description> <command> [container_id]
run_test_case() {
	description="$1"
	shift
	
	# Check if last argument looks like a container ID (starts with alphanumeric)
	# We need to parse all args to find if the last one is a container ID
	args=""
	container_id=""
	
	# Collect all arguments
	while [ $# -gt 0 ]; do
		if [ $# -eq 1 ]; then
			# Last argument - could be container_id or part of command
			# Check if it looks like a container ID (40+ hex chars or short container name)
			case "$1" in
				*\ *) 
					# Has space, definitely part of command
					args="$args $1"
					;;
				*)
					# No space - could be container ID or single-word command
					# If it's 12+ chars and alphanumeric, treat as container ID
					if [ ${#1} -ge 12 ]; then
						container_id="$1"
					else
						args="$args $1"
					fi
					;;
			esac
		else
			args="$args $1"
		fi
		shift
	done
	
	command="$args"
	
	# If container_id is provided, use existing container; otherwise create new one
	if [ -n "$container_id" ]; then
		container="$container_id"
		cleanup_after=false
	else
		# Start a container for this test
		container=$("$CONTAINER_RUNTIME" run -d \
			-v "$REPO_DIR:/dotfiles:Z" \
			"$IMAGE_NAME" \
			sleep infinity 2>&1)
		cleanup_after=true
	fi

	# Run the command in the container and capture output and exit code
	if output=$("$CONTAINER_RUNTIME" exec "$container" sh -c "$command" 2>&1); then
		exit_code=0
	else
		exit_code=$?
	fi

	# Clean up the container if we created it
	if [ "$cleanup_after" = true ]; then
		"$CONTAINER_RUNTIME" rm -f "$container" >/dev/null 2>&1 || true
	fi

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
# Always returns 0 to allow tests to continue even on failure
# If PROFILE_TEST_CONTAINER is set, uses that container; otherwise creates a new one
assert() {
	if [ -n "$PROFILE_TEST_CONTAINER" ]; then
		run_test_case "$@" "$PROFILE_TEST_CONTAINER" || true
	else
		run_test_case "$@" || true
	fi
}

# Run common tests that apply to all profiles
run_common_tests() {
	profile_name="$1"
	profile_dir="$REPO_DIR/profiles/$profile_name"

	printf "\n--- Common Tests ---\n" | tee -a "$REPORT_FILE"

	# Test 1: Check for syntax errors in install script
	if [ -f "$profile_dir/install.sh" ]; then
		assert "Install script has no syntax errors" \
			"sh -n /dotfiles/profiles/$profile_name/install.sh"
	fi

	# Test 2: Check for syntax errors in uninstall script
	if [ -f "$profile_dir/uninstall.sh" ]; then
		assert "Uninstall script has no syntax errors" \
			"sh -n /dotfiles/profiles/$profile_name/uninstall.sh"
	fi

	# Test 3: Install script exits successfully
	if [ -f "$profile_dir/install.sh" ]; then
		assert "Install script exits successfully" \
			"cd /dotfiles/profiles/$profile_name && sh install.sh"
	fi

	# Test 4: Install script is idempotent (runs twice successfully)
	if [ -f "$profile_dir/install.sh" ]; then
		assert "Install script exits successfully on second run (idempotent)" \
			"cd /dotfiles/profiles/$profile_name && sh install.sh && sh install.sh"
	fi

	# Test 5: Uninstall script exits successfully
	if [ -f "$profile_dir/uninstall.sh" ]; then
		assert "Uninstall script exits successfully" \
			"cd /dotfiles/profiles/$profile_name && sh uninstall.sh"
	fi

	# Test 6: Install then uninstall works
	if [ -f "$profile_dir/install.sh" ] && [ -f "$profile_dir/uninstall.sh" ]; then
		assert "Uninstall script exits successfully after an install" \
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

	# Run common tests for all profiles (each in their own container)
	run_common_tests "$profile_name"

	# Run profile-specific tests if they exist
	if [ -f "$profile_dir/tests.sh" ]; then
		printf "\n--- Profile-Specific Tests ---\n" | tee -a "$REPORT_FILE"
		
		# Start a container for profile-specific tests
		PROFILE_TEST_CONTAINER=$("$CONTAINER_RUNTIME" run -d \
			-v "$REPO_DIR:/dotfiles:Z" \
			"$IMAGE_NAME" \
			sleep infinity 2>&1)
		
		# Run the install script in the container first
		if [ -f "$profile_dir/install.sh" ]; then
			printf "Running install script in profile test container...\n"
			
			# Capture install output for the report
			if install_output=$("$CONTAINER_RUNTIME" exec "$PROFILE_TEST_CONTAINER" sh -c "cd /dotfiles/profiles/$profile_name && sh install.sh" 2>&1); then
				install_exit_code=0
			else
				install_exit_code=$?
			fi
			
			# Log the setup step to the report
			{
				printf "\n[SETUP] Install script for profile-specific tests\n"
				printf "Command: cd /dotfiles/profiles/%s && sh install.sh\n" "$profile_name"
				
				if [ -n "$install_output" ]; then
					printf "Output:\n%s\n" "$install_output"
				fi
				
				if [ $install_exit_code -eq 0 ]; then
					printf "[PASS] Setup completed successfully\n"
				else
					printf "[FAIL] Setup failed (exit code: %d)\n" "$install_exit_code"
				fi
			} >>"$REPORT_FILE"
		fi
		
		# Source the profile's test file and run tests (using the shared container)
		# shellcheck disable=SC1090
		. "$profile_dir/tests.sh" || true
		
		# Clean up the profile test container
		"$CONTAINER_RUNTIME" rm -f "$PROFILE_TEST_CONTAINER" >/dev/null 2>&1 || true
		PROFILE_TEST_CONTAINER=""
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
				run_profile_tests "$profile_name" || true
			fi
		done
	else
		# Run tests for specified profile
		run_profile_tests "$1" || true
	fi

	# Count failed tests
	failed_count=$(grep -c "^\[FAIL\]" "$REPORT_FILE" 2>/dev/null || echo "0")

	printf "\n========================================\n" | tee -a "$REPORT_FILE"
	printf "Test run complete. Report saved to: %s\n" "$REPORT_FILE"
	printf "Failed tests: %s\n" "$failed_count"
	printf "========================================\n"
	
	# Exit with the number of failed tests as the status code
	exit "$failed_count"
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
