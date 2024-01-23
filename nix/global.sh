#!/bin/bash

echo "Setting up global packages"

packages=(
  "jq"
  "yq"
  "bat"
  "tldr"
)

for package in "${packages[@]}"; do
    echo "Installing $package"
    nix-env --install --attr "nixpkgs.$package"
done

