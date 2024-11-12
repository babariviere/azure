#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

### Add repos

# Add Staging repo
curl -Lo /etc/yum.repos.d/ublue-os-staging-fedora-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-"${RELEASE}"/ublue-os-staging-fedora-"${RELEASE}".repo

# Add Bling repo
curl -Lo /etc/yum.repos.d/ublue-os-bling-fedora-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/ublue-os/bling/repo/fedora-"${RELEASE}"/ublue-os-bling-fedora-"${RELEASE}".repo

curl -Lo /etc/yum.repos.d/ganto-lxc4-fedora-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/ganto/lxc4/repo/fedora-"${RELEASE}"/ganto-lxc4-fedora-"${RELEASE}".repo

curl -Lo /etc/yum.repos.d/_copr_che-nerd-fonts-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/repo/fedora-"${RELEASE}"/che-nerd-fonts-fedora-"${RELEASE}".repo

curl -Lo /etc/yum.repos.d/_copr_babariviere-tools-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/babariviere/tools/repo/fedora-"${RELEASE}"/babariviere-tools-fedora-"${RELEASE}".repo

curl https://downloads.1password.com/linux/keys/1password.asc | tee /etc/pki/rpm-gpg/1password.gpg

### Install 1password using blue-build script

curl -Lo 1password.sh https://raw.githubusercontent.com/blue-build/modules/22fe11d844763bf30bd83028970b975676fe7beb/modules/bling/installers/1password.sh

chmod +x 1password.sh
bash ./1password.sh

rm 1password.sh

### Install packages

grep -v '^#' /tmp/packages | xargs rpm-ostree install

rpm-ostree install 1password

rpm-ostree override remove opensc

# Install topgrade
pip install --prefix=/usr topgrade

# Installed via flatpak
rpm-ostree override remove firefox firefox-langpacks

#### Quadlets

mkdir -p /etc/containers/systemd/users
curl -Lo /etc/containers/systemd/users/azure-cli.container https://raw.githubusercontent.com/babariviere/toolboxes/main/quadlets/azure-cli/azure-cli.container
sed -i 's/ContainerName=azure/ContainerName=azure-cli/' /etc/containers/systemd/users/azure-cli.container

# Make systemd targets
mkdir -p /usr/lib/systemd/user
QUADLET_TARGETS=(
  "azure-cli"
)
for i in "${QUADLET_TARGETS[@]}"; do
cat > "/usr/lib/systemd/user/${i}.target" <<EOF
[Unit]
Description=${i}"target for ${i} quadlet

[Install]
WantedBy=default.target
EOF
done

#### Services

# systemctl enable docker.socket
systemctl enable podman.socket
systemctl enable podman-auto-update.timer
# systemctl enable tailscaled.service
systemctl enable -f --global flatpak-setup.service
systemctl enable -f --global azure-topgrade.service
systemctl enable -f --global azure-cli.target

systemctl enable azure-system-setup.service
systemctl enable azure-groups.service
