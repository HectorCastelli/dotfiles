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

WORKDIR /dotfiles
