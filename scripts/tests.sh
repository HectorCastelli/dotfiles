#!/usr/bin/env sh
set -eu

# === Configuration ===
CONTAINER_RUNTIME=""
IMAGE_NAME="dotfiles-test"
REPORT_FILE="${REPORT_FILE:-test_report.txt}"
REPO_DIR="$(git rev-parse --show-toplevel)"
PROFILE_TEST_CONTAINER=""

# === Helper Functions ===

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

build_image() {
	printf "Building test image with %s...\n" "$CONTAINER_RUNTIME"
	"$CONTAINER_RUNTIME" build -t "$IMAGE_NAME" -f "$REPO_DIR/Containerfile" "$REPO_DIR"
}

# Run command in container and return output + exit code
# Args: <container_id> <command>
exec_in_container() {
	container="$1"
	command="$2"
	if output=$("$CONTAINER_RUNTIME" exec "$container" sh -c "$command" 2>&1); then
		exit_code=0
	else
		exit_code=$?
	fi
}

# Write test result to report
# Args: <description> <command> <output> <exit_code> [type]
write_test_result() {
	description="$1"
	command="$2"
	output="$3"
	exit_code="$4"
	test_type="${5:-TEST}"
	
	{
		printf "\n[%s] %s\n" "$test_type" "$description"
		printf "Command: %s\n" "$command"
		[ -n "$output" ] && printf "Output:\n%s\n" "$output"
		
		if [ "$exit_code" -eq 0 ]; then
			printf "[PASS] %s\n" "$description"
		else
			printf "[FAIL] %s (exit code: %d)\n" "$description" "$exit_code"
		fi
	} >>"$REPORT_FILE"
	
	# Print to stdout
	if [ "$exit_code" -eq 0 ]; then
		printf "[PASS] %s\n" "$description"
	else
		printf "[FAIL] %s (exit code: %d)\n" "$description" "$exit_code"
	fi
}

# Run a test case with automatic container management
# Args: <description> <command> [container_id]
run_test_case() {
	description="$1"
	command="$2"
	container_id="${3:-}"
	
	# Use existing container or create new one
	if [ -n "$container_id" ]; then
		container="$container_id"
		cleanup=false
	else
		container=$("$CONTAINER_RUNTIME" run -d \
			-v "$REPO_DIR:/dotfiles:Z" \
			"$IMAGE_NAME" \
			sleep infinity 2>&1)
		cleanup=true
	fi
	
	# Execute test
	exec_in_container "$container" "$command"
	
	# Cleanup if we created the container
	[ "$cleanup" = true ] && "$CONTAINER_RUNTIME" rm -f "$container" >/dev/null 2>&1 || true
	
	# Write result
	write_test_result "$description" "$command" "$output" "$exit_code"
	
	return "$exit_code"
}

# Public API: assert function for profile tests
# Usage: assert <description> <command>
assert() {
	run_test_case "$1" "$2" "$PROFILE_TEST_CONTAINER" || true
}

# === Test Runners ===

run_common_tests() {
	profile_name="$1"
	profile_dir="$REPO_DIR/profiles/$profile_name"
	
	printf "\n--- Common Tests ---\n" | tee -a "$REPORT_FILE"
	
	# Syntax checks
	[ -f "$profile_dir/install.sh" ] && \
		assert "Install script has no syntax errors" \
			"sh -n /dotfiles/profiles/$profile_name/install.sh"
	
	[ -f "$profile_dir/uninstall.sh" ] && \
		assert "Uninstall script has no syntax errors" \
			"sh -n /dotfiles/profiles/$profile_name/uninstall.sh"
	
	# Install tests
	[ -f "$profile_dir/install.sh" ] && \
		assert "Install script exits successfully" \
			"cd /dotfiles/profiles/$profile_name && sh install.sh"
	
	[ -f "$profile_dir/install.sh" ] && \
		assert "Install script is idempotent (runs twice)" \
			"cd /dotfiles/profiles/$profile_name && sh install.sh && sh install.sh"
	
	# Uninstall tests
	[ -f "$profile_dir/uninstall.sh" ] && \
		assert "Uninstall script exits successfully" \
			"cd /dotfiles/profiles/$profile_name && sh uninstall.sh"
	
	[ -f "$profile_dir/install.sh" ] && [ -f "$profile_dir/uninstall.sh" ] && \
		assert "Uninstall works after install" \
			"cd /dotfiles/profiles/$profile_name && sh install.sh && sh uninstall.sh"
}

run_profile_specific_tests() {
	profile_name="$1"
	profile_dir="$REPO_DIR/profiles/$profile_name"
	
	[ ! -f "$profile_dir/tests.sh" ] && return 0
	
	printf "\n--- Profile-Specific Tests ---\n" | tee -a "$REPORT_FILE"
	
	# Start container for profile tests
	PROFILE_TEST_CONTAINER=$("$CONTAINER_RUNTIME" run -d \
		-v "$REPO_DIR:/dotfiles:Z" \
		"$IMAGE_NAME" \
		sleep infinity 2>&1)
	
	# Run install as setup
	if [ -f "$profile_dir/install.sh" ]; then
		printf "Running install script in profile test container...\n"
		command="cd /dotfiles/profiles/$profile_name && sh install.sh"
		exec_in_container "$PROFILE_TEST_CONTAINER" "$command"
		write_test_result "Install script for profile-specific tests" "$command" "$output" "$exit_code" "SETUP"
	fi
	
	# Run profile-specific tests
	# shellcheck disable=SC1090
	. "$profile_dir/tests.sh" || true
	
	# Cleanup
	"$CONTAINER_RUNTIME" rm -f "$PROFILE_TEST_CONTAINER" >/dev/null 2>&1 || true
	PROFILE_TEST_CONTAINER=""
}

run_profile_tests() {
	profile_name="$1"
	profile_dir="$REPO_DIR/profiles/$profile_name"
	
	[ ! -d "$profile_dir" ] && {
		printf "Profile '%s' not found\n" "$profile_name" >&2
		return 1
	}
	
	{
		printf "\n========================================\n"
		printf "Testing profile: %s\n" "$profile_name"
		printf "========================================\n"
	} | tee -a "$REPORT_FILE"
	
	run_common_tests "$profile_name"
	run_profile_specific_tests "$profile_name"
}

run_all_profiles() {
	for profile_dir in "$REPO_DIR/profiles"/*; do
		[ ! -d "$profile_dir" ] && continue
		profile_name=$(basename "$profile_dir")
		[ "$profile_name" = "_template" ] && continue
		run_profile_tests "$profile_name" || true
	done
}

run_tests() {
	# Initialize report
	printf "Test Report - %s\n" "$(date)" >"$REPORT_FILE"
	printf "========================================\n\n" >>"$REPORT_FILE"
	
	build_image
	
	# Run tests for all or specific profile
	if [ $# -eq 0 ]; then
		run_all_profiles
	else
		run_profile_tests "$1" || true
	fi
	
	# Report summary
	failed_count=$(grep -c "^\[FAIL\]" "$REPORT_FILE" 2>/dev/null || echo "0")
	
	printf "\n========================================\n" | tee -a "$REPORT_FILE"
	printf "Test run complete. Report saved to: %s\n" "$REPORT_FILE"
	printf "Failed tests: %s\n" "$failed_count"
	printf "========================================\n"
	
	exit "$failed_count"
}

# === Main Entry Point ===

detect_container_runtime

case "${1:-}" in
	build_image)
		build_image
		;;
	run_tests)
		shift
		run_tests "$@"
		;;
	help)
		printf "Usage: %s <command>\n\n" "$(basename "$0")"
		printf "Available commands:\n"
		printf "  build_image       Build the test container image\n"
		printf "  run_tests [prof]  Run tests for all profiles or a specific profile\n"
		printf "  help              Show this help message\n"
		;;
	*)
		run_tests "$@"
		;;
esac
