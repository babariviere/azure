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

curl -Lo /etc/yum.repos.d/_copr_babariviere-tools-"${FEDORA_MAJOR_VERSION}".repo https://copr.fedorainfracloud.org/coprs/babariviere/tools/repo/fedora-"${FEDORA_MAJOR_VERSION}"/babariviere-tools-fedora-"${FEDORA_MAJOR_VERSION}".repo
### Install packages

grep -v '^#' /tmp/packages | xargs rpm-ostree install

rpm-ostree override remove opensc


# Install topgrade
pip install --prefix=/usr topgrade

# Installed via flatpak
rpm-ostree override remove firefox firefox-langpacks

#### Services

systemctl enable docker.socket
systemctl enable incus.socket
systemctl enable podman.socket
systemctl enable tailscaled.service
systemctl enable -f --global flatpak-setup.service
systemctl enable -f --global azure-topgrade.service
systemctl enable -f --global emacs.service

systemctl enable azure-system-setup.service
systemctl enable azure-groups.service
