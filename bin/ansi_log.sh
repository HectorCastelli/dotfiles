#!/bin/sh

# ANSI escape codes for colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m' # Added light blue
RESET='\033[0m'   # Reset to default color

info() {
  printf "${BLUE}? %s${RESET}\n" "$1" >&1
}

debug() {
  printf "${CYAN}%s${RESET}\n" "$1" >&1
}

success() {
  printf "${GREEN}✓ %s${RESET}\n" "$1" >&1
}

error() {
  printf "${RED}✗ %s${RESET}\n" "$1" >&2
}

warn() {
  printf "${YELLOW}! %s${RESET}\n" "$1" >&2
}
