#!/bin/sh

# ANSI escape codes for colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m' # Reset to default color

info() {
  printf "${BLUE}? %s${RESET}\n" "$1"
}

success() {
  printf "${GREEN}✓ %s${RESET}\n" "$1"
}

error() {
  printf "${RED}✗ %s${RESET}\n" "$1"
}

warn() {
  printf "${YELLOW}! %s${RESET}\n" "$1"
}