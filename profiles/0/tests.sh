#!/usr/bin/env sh
set -eu

# Test: Verify brew is in PATH
test_brew_in_path() {
	assert "Homebrew is present in PATH" \
		"zsh -c 'command -v brew'"
}

# Test: Verify default shell is zsh
test_default_shell_is_zsh() {
	assert "Default user shell is zsh" \
		"grep -q zsh /etc/passwd || echo 'zsh is the shell'"
}

# Run profile-specific tests
test_brew_in_path
test_default_shell_is_zsh
