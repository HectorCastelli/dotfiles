# Using the latest Fedora base image
FROM registry.fedoraproject.org/fedora:latest

# Install prerequisites as specified in scripts/get.sh
RUN dnf install -y \
    git \
    curl \
    bash \
    which \
    util-linux-core

RUN dnf clean all

# Copy get.sh to verify installation
COPY scripts/get.sh /tmp/get.sh
# Run the check function to ensure installation is healthy
RUN sh /tmp/get.sh check

# Setup initial git configuration for tests
RUN git config --global user.name "Test User" && \
    git config --global user.email "test@dotfiles.repo"

# Set working directory to /dotfiles
WORKDIR /dotfiles
ENV DOTFILES_DIR="/dotfiles"

# Sets the default command as the sh shell
CMD ["/bin/sh"]