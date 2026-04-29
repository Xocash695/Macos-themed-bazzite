#!/bin/bash

set -ouex pipefail

### Install packages
# 1. MacTahoe GTK Theme (The "Shirt")
# The installer might fail if these don't exist yet
#
dnf install -y sassc
dnf install -y vlc
dnf install -y firefox
dnf install -y zsh

# Install Oh My Zsh system-wide into skel so all new users get it
git clone https://github.com/ohmyzsh/ohmyzsh.git /etc/skel/.oh-my-zsh
cp /etc/skel/.oh-my-zsh/templates/zshrc.zsh-template /etc/skel/.zshrc

# Set zsh as default shell for new users
sed -i 's|SHELL=.*|SHELL=/bin/zsh|' /etc/default/useradd

mkdir -p /usr/share/themes
mkdir -p /usr/share/icons


# 2. GTK THEME
# We add the '-p' flag which most of Vince's scripts use for 'path'
# and ensure we are running it without interactive prompts
# GTK Theme
dnf install -y sassc bc glib2-devel

# GTK Theme - must specify dest since default is ~/.themes
git clone https://github.com/vinceliuice/MacTahoe-gtk-theme.git --depth=1 /tmp/tahoe-gtk
cd /tmp/tahoe-gtk
bash -x ./install.sh --silent-mode 2>&1 | tail -50 || true
# Icon Theme
git clone https://github.com/vinceliuice/MacTahoe-icon-theme.git --depth=1 /tmp/tahoe-icons
cd /tmp/tahoe-icons
./install.sh -d /usr/share/icons

# KDE Theme - installs to /usr/share automatically when run as root
git clone https://github.com/vinceliuice/MacTahoe-kde.git --depth=1 /tmp/tahoe-kde
cd /tmp/tahoe-kde
./install.sh

# change boot logo:
# # Download the Apple Plymouth theme

# Install Plymouth theme
#
rpm -q plymouth || true
git clone https://github.com/Msouza91/apple-mac-plymouth.git /tmp/apple-plymouth

# Install Apple Plymouth theme
git clone https://github.com/Msouza91/apple-mac-plymouth.git /tmp/apple-plymouth

PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/apple-mac-plymouth"
mkdir -p "$PLYMOUTH_THEME_DIR"
cp -r /tmp/apple-plymouth/* "$PLYMOUTH_THEME_DIR/"

# Set theme in both config locations to be safe
mkdir -p /etc/plymouth
cat > /etc/plymouth/plymouthd.conf << 'EOF'
[Daemon]
Theme=apple-mac-plymouth
ShowDelay=0
EOF

# Also update the defaults file if it exists
if [ -f /usr/share/plymouth/plymouthd.defaults ]; then
    sed -i 's/^Theme=.*/Theme=apple-mac-plymouth/' /usr/share/plymouth/plymouthd.defaults
fi
# Also set it in the runtime config location
mkdir -p /etc/plymouth
cat > /etc/plymouth/plymouthd.conf << 'EOF'
[Daemon]
Theme=apple-mac-plymouth
ShowDelay=0
EOF

# set theme by default
# mkdir -p /etc/skel/.config

# Set the Global Theme (Window look, Colors, Splash screen)
# This command tells Plasma to use the MacTahoe look and feel

# Install Kvantum
dnf install -y kvantum

# Set up skel configs
mkdir -p /etc/skel/.config/Kvantum

cat > /etc/skel/.config/Kvantum/kvantum.kvconfig << 'EOF'
[General]
theme=MacTahoe
EOF

cat > /etc/skel/.config/kdeglobals << 'EOF'
[Icons]
Theme=MacTahoe

[KDE]
LookAndFeelPackage=MacTahoe

[General]
widgetStyle=kvantum
EOF

cat > /etc/skel/.config/plasmarc << 'EOF'
[Theme]
name=MacTahoe
EOF

# Set it as the default theme
# Note: In an image build, we use the path to the .plymouth file
#
# using ulauncher
dnf install -y ulauncher

# Install Liquid Glass theme
git clone https://github.com/kayozxo/ulauncher-liquid-glass.git /tmp/ulauncher-liquid-glass
cd /tmp/ulauncher-liquid-glass
./install.sh
# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux

# this was to make sure the keys were there
# cat /etc/yum.repos.d/terra*.repo || true
# ls /etc/pki/rpm-gpg/ || true

sed -i 's/gpgcheck=1/gpgcheck=0/g; /gpgkey=file:\/\//d' /etc/yum.repos.d/terra-mesa.repo
# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging



#### Example for enabling a System Unit File

systemctl enable podman.socket
