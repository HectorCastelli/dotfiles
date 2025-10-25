#!/usr/bin/env sh
set -eu

# This is a template for profile tests
# Copy this file to your profile directory and implement the test cases

# Test 1: Install script runs successfully once
test_install_once() {
	assert "Install script exits successfully on first run" \
		"cd /dotfiles/profiles/_template && sh install.sh"
}

# Test 2: Install script is idempotent (can run twice)
test_install_idempotent() {
	assert "Install script exits successfully on first run" \
		"cd /dotfiles/profiles/_template && sh install.sh"
	assert "Install script exits successfully on second run (idempotent)" \
		"cd /dotfiles/profiles/_template && sh install.sh"
}

# Test 3: Install then uninstall works
test_install_uninstall() {
	assert "Install script exits successfully" \
		"cd /dotfiles/profiles/_template && sh install.sh"
	assert "Uninstall script exits successfully" \
		"cd /dotfiles/profiles/_template && sh uninstall.sh"
}

# Run all tests
test_install_once
test_install_idempotent
test_install_uninstall
