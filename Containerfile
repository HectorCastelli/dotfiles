FROM fedora:latest

# Install basic prerequisites
RUN dnf install -y \
    git \
    curl \
    bash \
    coreutils \
    && dnf clean all

# Create a directory for mounting the repository
RUN mkdir -p /dotfiles

WORKDIR /dotfiles
