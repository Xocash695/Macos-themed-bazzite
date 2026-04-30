#!/bin/bash
set -ouex pipefail

### Install packages
dnf install -y sassc zsh
useradd -D -s /bin/zsh

# Oh My Zsh system-wide
git clone https://github.com/ohmyzsh/ohmyzsh.git /etc/skel/.oh-my-zsh
cp /etc/skel/.oh-my-zsh/templates/zshrc.zsh-template /etc/skel/.zshrc
sed -i 's|SHELL=.*|SHELL=/bin/zsh|' /etc/default/useradd

# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    /etc/skel/.oh-my-zsh/custom/themes/powerlevel10k
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /etc/skel/.zshrc

flatpak override --filesystem=xdg-config/gtk-3.0
flatpak override --filesystem=xdg-config/gtk-4.0
flatpak install -y flathub org.mozilla.firefox
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
printf '[Daemon]\nTheme=apple-mac-plymouth\nShowDelay=0\n' > /etc/plymouth/plymouthd.conf

if [ -f /usr/share/plymouth/plymouthd.defaults ]; then
    sed -i 's/^Theme=.*/Theme=apple-mac-plymouth/' /usr/share/plymouth/plymouthd.defaults
fi

# Regenerate initramfs on first boot to apply Plymouth theme
printf '[Unit]\nDescription=Set Plymouth theme on first boot\nConditionPathExists=!/var/lib/plymouth-theme-set\nAfter=local-fs.target\n\n[Service]\nType=oneshot\nExecStart=/usr/sbin/plymouth-set-default-theme -R apple-mac-plymouth\nExecStartPost=/usr/bin/touch /var/lib/plymouth-theme-set\nRemainAfterExit=yes\n\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/plymouth-theme-set.service

systemctl enable plymouth-theme-set.service

# KDE skel configs
mkdir -p /etc/skel/.config/gtk-3.0
mkdir -p /etc/skel/.config/gtk-4.0

printf '[Icons]\nTheme=MacTahoe\n\n[KDE]\nLookAndFeelPackage=MacTahoe\n' > /etc/skel/.config/kdeglobals

printf '[Theme]\nname=MacTahoe\n' > /etc/skel/.config/plasmarc

printf '[Settings]\ngtk-theme-name=MacTahoe\ngtk-icon-theme-name=MacTahoe\n' > /etc/skel/.config/gtk-3.0/settings.ini

printf '[Settings]\ngtk-theme-name=MacTahoe\ngtk-icon-theme-name=MacTahoe\n' > /etc/skel/.config/gtk-4.0/settings.ini

# Fix terra-mesa GPG key issue for ISO builds
sed -i 's/gpgcheck=1/gpgcheck=0/g; /gpgkey=file:\/\//d' /etc/yum.repos.d/terra-mesa.repo

# Extra packages
dnf install -y tmux

# Enable services
systemctl enable podman.socket
