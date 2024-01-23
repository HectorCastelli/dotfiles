#!/bin/bash

echo "Setting up global packages"

packages=(
  "jq"
  "yq"
  "bat"
  "tldr"
  "lnav"
  "glow"
  "hyperfine"
)

for package in "${packages[@]}"; do
  echo "Installing $package"
  nix-env --install --attr "nixpkgs.$package"
done
