FROM docker.io/fedora:latest

# Note: This Containerfile is minimal as the base Fedora image includes
# most necessary tools (bash, coreutils, etc.)
# The repository will be mounted at /dotfiles during container runtime

WORKDIR /dotfiles
