#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

### Add repos

# Add Staging repo
curl -Lo /etc/yum.repos.d/ublue-os-staging-fedora-"${FEDORA_MAJOR_VERSION}".repo https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-"${FEDORA_MAJOR_VERSION}"/ublue-os-staging-fedora-"${FEDORA_MAJOR_VERSION}".repo

# Add Bling repo
curl -Lo /etc/yum.repos.d/ublue-os-bling-fedora-"${FEDORA_MAJOR_VERSION}".repo https://copr.fedorainfracloud.org/coprs/ublue-os/bling/repo/fedora-"${FEDORA_MAJOR_VERSION}"/ublue-os-bling-fedora-"${FEDORA_MAJOR_VERSION}".repo

curl -Lo /etc/yum.repos.d/ganto-lxc4-fedora-"${FEDORA_MAJOR_VERSION}".repo https://copr.fedorainfracloud.org/coprs/ganto/lxc4/repo/fedora-"${FEDORA_MAJOR_VERSION}"/ganto-lxc4-fedora-"${FEDORA_MAJOR_VERSION}".repo

curl -Lo /etc/yum.repos.d/_copr_che-nerd-fonts-"${FEDORA_MAJOR_VERSION}".repo https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/repo/fedora-"${FEDORA_MAJOR_VERSION}"/che-nerd-fonts-fedora-"${FEDORA_MAJOR_VERSION}".repo

### Install packages

grep -v '^#' /tmp/packages | xargs rpm-ostree install

rpm-ostree override remove opensc

### Setup flatpaks

mkdir -p /etc/azure/flatpaks
cp /tmp/build/flatpak-setup /usr/bin/flatpak-setup
cp /tmp/build/flatpak-setup.service /usr/lib/systemd/user/flatpak-setup.service

#### Services

systemctl enable podman.socket
systemctl enable tailscaled.service
systemctl enable -f --global flatpak-setup.service
