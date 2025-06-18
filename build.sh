#!/bin/bash

set -ouex pipefail

### Add repos

# Add niri repo
dnf5 -y copr enable yalter/niri

# Add Staging repo
dnf5 -y copr enable ublue-os/staging

# Add Bling repo
dnf5 -y copr enable ublue-os/bling

dnf5 -y copr enable ganto/lxc4

dnf5 -y copr enable che/nerd-fonts

dnf5 -y copr enable pgdev/ghostty

dnf5 -y copr enable alternateved/bleeding-emacs

dnf5 -y copr enable ulysg/xwayland-satellite

curl https://downloads.1password.com/linux/keys/1password.asc | tee /etc/pki/rpm-gpg/1password.gpg

dnf5 -y copr enable gmaglione/podman-bootc

### Install 1password using blue-build script

curl -Lo 1password.sh https://raw.githubusercontent.com/blue-build/modules/22fe11d844763bf30bd83028970b975676fe7beb/modules/bling/installers/1password.sh

chmod +x 1password.sh
bash ./1password.sh

rm 1password.sh

### Install packages

grep -v '^#' /tmp/packages | xargs dnf5 install -y

# Install topgrade
pip install --prefix=/usr topgrade

#### os-release

echo "VARIANT=Azure" && echo "VARIANT_ID=com.babariviere.azure" >> /usr/lib/os-release

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

dnf5 -y copr disable yalter/niri

# Add Staging repo
dnf5 -y copr disable ublue-os/staging

# Add Bling repo
dnf5 -y copr disable ublue-os/bling

dnf5 -y copr disable ganto/lxc4

dnf5 -y copr disable che/nerd-fonts

dnf5 -y copr disable pgdev/ghostty

dnf5 -y copr disable alternateved/bleeding-emacs

dnf5 -y copr disable ulysg/xwayland-satellite

curl https://downloads.1password.com/linux/keys/1password.asc | tee /etc/pki/rpm-gpg/1password.gpg

dnf5 -y copr disable gmaglione/podman-bootc

rm -rf /var/log
