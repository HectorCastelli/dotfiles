#!/usr/bin/env sh

# Use all CPU cores, fallback to 4
HOMEBREW_MAKE_JOBS=$(nproc 2>/dev/null || echo "4")
export HOMEBREW_MAKE_JOBS
# Enable parallel downloads
export HOMEBREW_PARALLEL=1
# Auto-remove unused dependencies
export HOMEBREW_AUTOREMOVE=1
# Full cleanup every 7 days
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=7
# Remove downloads older than 120 days
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=120
# Cache management
export HOMEBREW_CACHE="$HOME/.cache/homebrew"
export HOMEBREW_LOGS="$HOME/.cache/homebrew/logs"
# Create cache directories if they don't exist
if [ ! -d "$HOMEBREW_CACHE" ]; then
	mkdir -p "$HOMEBREW_CACHE"
fi
if [ ! -d "$HOMEBREW_LOGS" ]; then
	mkdir -p "$HOMEBREW_LOGS"
fi
# Disable analytics collection
export HOMEBREW_NO_ANALYTICS=1
# Prevent insecure redirects
export HOMEBREW_NO_INSECURE_REDIRECT=1
# Reduce environment setup hints
export HOMEBREW_NO_ENV_HINTS=1
# Show install duration
export HOMEBREW_DISPLAY_INSTALL_TIMES=1
# Show progress dots instead of full verbose
export HOMEBREW_VERBOSE_USING_DOTS=1
# Cleaner output without emoji
export HOMEBREW_NO_EMOJI=1

if [ "$(uname)" = "Darwin" ]; then
	# Install applications and fonts to the correct MacOS directories
	export HOMEBREW_CASK_OPTS="--appdir=/Applications --fontdir=/Library/Fonts"
fi
