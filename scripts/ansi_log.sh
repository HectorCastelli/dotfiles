#!/bin/bash

# ANSI escape codes for colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'  # Reset to default color

info() {
  echo -e "${BLUE}? $1${RESET}"
}

success() {
  echo -e "${GREEN}✓ $1${RESET}"
}

error() {
  echo -e "${RED}✗ $1${RESET}"
}

warn() {
  echo -e "${YELLOW}! $1${RESET}"
}