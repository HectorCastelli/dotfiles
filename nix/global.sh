#!/bin/bash

echo "Setting up global packages"

packages=(
  "bat"
  "gh"
  "glow"
  "hyperfine"
  "jq"
  "lnav"
  "tldr"
  "vscode"
  "yq"
)

for package in "${packages[@]}"; do
  echo "Installing $package"
  nix-env --install --attr "nixpkgs.$package"
done
