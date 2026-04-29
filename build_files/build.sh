#!/bin/bash

set -ouex pipefail

### Install packages
# 1. MacTahoe GTK Theme (The "Shirt")
# The installer might fail if these don't exist yet
#
dnf install -y sassc bc gtk-murrine-engine
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
git clone https://github.com/Msouza91/apple-mac-plymouth.git /tmp/apple-plymouth

PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/apple-mac-plymouth"
mkdir -p "$PLYMOUTH_THEME_DIR"
cp -r /tmp/apple-plymouth/* "$PLYMOUTH_THEME_DIR/"

# Point the default symlink at our theme — no initramfs rebuild needed
PLYMOUTH_CONF="/usr/share/plymouth/plymouthd.defaults"
sed -i 's/^Theme=.*/Theme=apple-mac-plymouth/' "$PLYMOUTH_CONF" || \
    echo -e "[Daemon]\nTheme=apple-mac-plymouth" > "$PLYMOUTH_CONF"

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
mkdir -p /etc/skel/.config/plasma-workspace/env
echo "lookandfeeltool -a MacTahoe" > /etc/skel/.config/plasma-workspace/env/set-theme.sh
chmod +x /etc/skel/.config/plasma-workspace/env/set-theme.sh

# Set the Icon Theme specifically
cat <<EOF > /etc/skel/.config/kdeglobals
[Icons]
Theme=MacTahoe
EOF

# Set it as the default theme
# Note: In an image build, we use the path to the .plymouth file

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux

# this was to make sure the keys were there
# cat /etc/yum.repos.d/terra*.repo || true
# ls /etc/pki/rpm-gpg/ || true

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-terra44-mesa
# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
