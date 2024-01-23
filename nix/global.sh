#!/bin/bash

echo "Setting up global packages"

packages=(
  "bat"
  "glow"
  "hyperfine"
  "jq"
  "lnav"
  "tldr"
  "yq"
)

for package in "${packages[@]}"; do
  echo "Installing $package"
  nix-env --install --attr "nixpkgs.$package"
done
