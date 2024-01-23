#!/bin/sh


# Example usage
# display_in_color "red" "This is red text!"
# display_in_color "green" "This is green text!"
# display_in_color "yellow" "This is yellow text!"
# display_in_color "" "This defaults to green text!"
display_in_color() {
  # Define ANSI escape codes for colors
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  RESET='\033[0m'  # Reset ANSI escape code to default color

  # Determine color based on the first argument
  case "$1" in
    "red")
      COLOR="$RED"
      ;;
    "green")
      COLOR="$GREEN"
      ;;
    "yellow")
      COLOR="$YELLOW"
      ;;
    *)
      # Default to green if no valid color specified
      COLOR="$GREEN"
      ;;
  esac

  # Print the input string in the specified color
  echo -e "${COLOR}$2${RESET}"
}
