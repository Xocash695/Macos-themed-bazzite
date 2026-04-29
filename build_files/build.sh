#!/bin/bash
set -ouex pipefail

### Install packages
dnf install -y sassc zsh kvantum ulauncher

# Oh My Zsh system-wide
git clone https://github.com/ohmyzsh/ohmyzsh.git /etc/skel/.oh-my-zsh
cp /etc/skel/.oh-my-zsh/templates/zshrc.zsh-template /etc/skel/.zshrc
sed -i 's|SHELL=.*|SHELL=/bin/zsh|' /etc/default/useradd

# ULauncher Liquid Glass theme
git clone https://github.com/kayozxo/ulauncher-liquid-glass.git /tmp/ulauncher-liquid-glass
cd /tmp/ulauncher-liquid-glass
./install.sh

# MacTahoe GTK Theme
mkdir -p /usr/share/themes
mkdir -p /usr/share/icons

git clone https://github.com/vinceliuice/MacTahoe-gtk-theme.git --depth=1 /tmp/tahoe-gtk
cd /tmp/tahoe-gtk
./install.sh --silent-mode 2>&1 | tail -50 || true

# MacTahoe Icon Theme
git clone https://github.com/vinceliuice/MacTahoe-icon-theme.git --depth=1 /tmp/tahoe-icons
cd /tmp/tahoe-icons
./install.sh -d /usr/share/icons

# MacTahoe KDE Theme
git clone https://github.com/vinceliuice/MacTahoe-kde.git --depth=1 /tmp/tahoe-kde
cd /tmp/tahoe-kde
./install.sh

# Apple Plymouth theme
git clone https://github.com/Msouza91/apple-mac-plymouth.git /tmp/apple-plymouth
PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/apple-mac-plymouth"
mkdir -p "$PLYMOUTH_THEME_DIR"
cp -r /tmp/apple-plymouth/* "$PLYMOUTH_THEME_DIR/"

mkdir -p /etc/plymouth
cat > /etc/plymouth/plymouthd.conf << 'EOF'
[Daemon]
Theme=apple-mac-plymouth
ShowDelay=0
EOF

if [ -f /usr/share/plymouth/plymouthd.defaults ]; then
    sed -i 's/^Theme=.*/Theme=apple-mac-plymouth/' /usr/share/plymouth/plymouthd.defaults
fi

# KDE skel configs
mkdir -p /etc/skel/.config/Kvantum
mkdir -p /etc/skel/.config/gtk-3.0
mkdir -p /etc/skel/.config/gtk-4.0

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

cat > /etc/skel/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=MacTahoe
gtk-icon-theme-name=MacTahoe
EOF

cat > /etc/skel/.config/gtk-4.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=MacTahoe
gtk-icon-theme-name=MacTahoe
EOF

# Fix terra-mesa GPG key issue for ISO builds
sed -i 's/gpgcheck=1/gpgcheck=0/g; /gpgkey=file:\/\//d' /etc/yum.repos.d/terra-mesa.repo

# Extra packages
dnf install -y tmux

# Enable services
systemctl enable podman.socket
