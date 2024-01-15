#!/bin/sh

echo "Setting up global packages"
nix-env --install --attr nixpkgs.jq
nix-env --install --attr nixpkgs.yq
nix-env --install --attr nixpkgs.vscode
nix-env --install --attr nixpkgs.bat

