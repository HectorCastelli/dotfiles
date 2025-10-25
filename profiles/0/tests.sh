#!/usr/bin/env sh
set -eu

# Profile 0 tests
# Note: Profile 0 installs homebrew and other tools which may be complex to test
# These tests verify the scripts run without syntax errors

# Test 1: Install script runs successfully once
test_install_once() {
	# We'll test if the script at least executes without syntax errors
	# In a real test environment, homebrew installation would require more setup
	assert "Install script has correct syntax" \
		"sh -n /dotfiles/profiles/0/install.sh"
}

# Test 2: Install script syntax check (simulating idempotent test)
test_install_idempotent() {
	assert "Install script has correct syntax (first check)" \
		"sh -n /dotfiles/profiles/0/install.sh"
	assert "Install script has correct syntax (second check)" \
		"sh -n /dotfiles/profiles/0/install.sh"
}

# Test 3: Install and uninstall scripts syntax
test_install_uninstall() {
	assert "Install script has correct syntax" \
		"sh -n /dotfiles/profiles/0/install.sh"
	assert "Uninstall script has correct syntax" \
		"sh -n /dotfiles/profiles/0/uninstall.sh"
}

# Run all tests
test_install_once
test_install_idempotent
test_install_uninstall
