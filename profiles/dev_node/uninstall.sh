#!/usr/bin/env bash
set -eu

if command -v fnm >/dev/null 2>&1; then
	# Uninstalling all versions managed by fnm
	fnm list | grep -v "system" | awk '{print $1}' | xargs -r fnm uninstall

	# Uninstalling fnm with brew
	brew uninstall fnm 2>/dev/null || true
fi
