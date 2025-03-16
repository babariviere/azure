#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

### Add repos

# Add niri repo
curl -Lo /etc/yum.repos.d/yalter-niri-fedora-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/yalter/niri/repo/fedora-"${RELEASE}"/yalter-niri-fedora-"${RELEASE}".repo

# Add Staging repo
curl -Lo /etc/yum.repos.d/ublue-os-staging-fedora-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-"${RELEASE}"/ublue-os-staging-fedora-"${RELEASE}".repo

# Add Bling repo
curl -Lo /etc/yum.repos.d/ublue-os-bling-fedora-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/ublue-os/bling/repo/fedora-"${RELEASE}"/ublue-os-bling-fedora-"${RELEASE}".repo

curl -Lo /etc/yum.repos.d/ganto-lxc4-fedora-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/ganto/lxc4/repo/fedora-"${RELEASE}"/ganto-lxc4-fedora-"${RELEASE}".repo

curl -Lo /etc/yum.repos.d/_copr_che-nerd-fonts-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/repo/fedora-"${RELEASE}"/che-nerd-fonts-fedora-"${RELEASE}".repo

curl -Lo /etc/yum.repos.d/_copr_pgdev-ghostty-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/pgdev/ghostty/repo/fedora-"${RELEASE}"/pgdev-ghostty-fedora-"${RELEASE}".repo

curl -Lo /etc/yum.repos.d/_copr_alternateved-bleeding-emacs-"${RELEASE}".repo https://copr.fedorainfracloud.org/coprs/alternateved/bleeding-emacs/repo/fedora-"${RELEASE}"/alternateved-bleeding-emacs-fedora-"${RELEASE}".repo

curl -Lo /etc/yum.repos.d/_copr-sneexy-zen-browser-"${RELEASE}".repo  https://copr.fedorainfracloud.org/coprs/sneexy/zen-browser/repo/fedora-$(rpm -E %fedora)/sneexy-zen-browsder-fedora-"${RELEASE}".repo

curl https://downloads.1password.com/linux/keys/1password.asc | tee /etc/pki/rpm-gpg/1password.gpg

### Install 1password using blue-build script

curl -Lo 1password.sh https://raw.githubusercontent.com/blue-build/modules/22fe11d844763bf30bd83028970b975676fe7beb/modules/bling/installers/1password.sh

chmod +x 1password.sh
bash ./1password.sh

rm 1password.sh

### Install packages

grep -v '^#' /tmp/packages | xargs rpm-ostree install

rpm-ostree install 1password zen-browser

# Install topgrade
pip install --prefix=/usr topgrade

# Installed via flatpak
rpm-ostree override remove firefox firefox-langpacks

#### os-release

sed -i '/fedoraproject.org/d' /usr/lib/os-release
sed -i 's/Fedora Linux/Azure/g' /usr/lib/os-release
sed -i 's/fedoraproject/babariviere/g' /usr/lib/os-release
sed -i 's/fedora/azure/g' /usr/lib/os-release
sed -i '/REDHAT/d' /usr/lib/os-release

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
Description="target for ${i} quadlet

[Install]
WantedBy=default.target
EOF

    printf "\n\n[Install]\nWantedBy=%s.target" "$i" >> /etc/containers/systemd/users/"$i".container
done

#### Setup devpod

ln -s /usr/bin/devpod-cli /usr/bin/devpod

#### Setup niri deps

mkdir /usr/lib/systemd/user/niri.service.wants
ln -s /usr/lib/systemd/user/mako.service /usr/lib/systemd/user/niri.service.wants/
ln -s /usr/lib/systemd/user/waybar.service /usr/lib/systemd/user/niri.service.wants/
ln -s /usr/lib/systemd/user/swayidle.service /usr/lib/systemd/user/niri.service.wants/
ln -s /usr/lib/systemd/user/kanshi.service /usr/lib/systemd/user/niri.service.wants/

#### Services

systemctl enable podman.socket
systemctl enable -f --global podman.socket
systemctl enable podman-auto-update.timer
systemctl enable greetd.service

systemctl enable tlp.service

systemctl enable -f --global flatpak-setup.service
systemctl enable -f --global azure-topgrade.service
systemctl enable -f --global syncthing.service

systemctl enable azure-system-setup.service
systemctl enable azure-groups.service
