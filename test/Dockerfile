# Minimal Ubuntu, as close to a fresh machine as practical: no sudo/curl/git beyond what install.sh needs to bootstrap.
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends sudo curl ca-certificates git \
    && rm -rf /var/lib/apt/lists/*

# Non-root user with passwordless sudo, like a normal dev box. SHELL/USER are set
# because docker doesn't set them and install.sh (set -u) reads them.
RUN useradd -m -s /bin/bash dev \
    && echo 'dev ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/dev
USER dev
ENV USER=dev HOME=/home/dev SHELL=/bin/bash TERM=xterm-256color
WORKDIR /home/dev
