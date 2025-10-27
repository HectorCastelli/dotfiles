#!/usr/bin/env sh
set -eu

# Test: Verify brew is in PATH
test_brew_in_path() {
	assert "Homebrew is present in PATH" \
		"command -v brew"
}

# Test: Verify default shell is zsh
test_default_shell_is_zsh() {
	assert "Default user shell is zsh" \
		"zsh -c 'echo \$SHELL | grep -q zsh'"
}

# Run profile-specific tests
test_brew_in_path
test_default_shell_is_zsh
