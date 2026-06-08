#!/bin/bash
set -ouex pipefail

# ==============================================================================
# 1. CORE PACKAGES & DEPENDENCIES
# ==============================================================================
dnf install -y sassc zsh plymouth-plugin-script tmux jq kpackagetool6

# Configure default system shell parameters
useradd -D -s /bin/zsh
sed -i 's|SHELL=.*|SHELL=/bin/zsh|' /etc/default/useradd

# Fix zsh compinit permissions
chmod 755 /usr/share/zsh
chmod 755 /usr/share/zsh/site-functions
chmod 644 /usr/share/zsh/site-functions/*

# ==============================================================================
# 2. GLOBAL DIRECTORY INITIALIZATION
# ==============================================================================
mkdir -p /usr/share/themes
mkdir -p /usr/share/icons
mkdir -p /usr/share/sddm/themes
mkdir -p /usr/share/plasma/plasmoids

# ==============================================================================
# 5. PLASMOIDS & EXTENSION WIDGETS DEPLOYMENT
# ==============================================================================
# Nothing KDE Widgets
git clone https://github.com/jaxparrow07/nothing-kde-widgets.git --depth=1 /tmp/nothing-kde-widgets
cd /tmp/nothing-kde-widgets
for widget_dir in packages/*/; do
    if [ -d "$widget_dir" ] && [ -f "${widget_dir}metadata.json" ]; then
        kpackagetool6 --type=Plasma/Applet --packageroot /usr/share/plasma/plasmoids -i "${widget_dir%/}" || true
    fi
done

# Extract fonts included in the widget package
mkdir -p /usr/share/fonts/truetype/nothing
find /tmp/nothing-kde-widgets/ -name "*.ttf" -o -name "*.otf" -exec cp {} /usr/share/fonts/truetype/nothing/ \;
fc-cache -f &>/dev/null || true

# DarwinMenu Plasmoid
curl -L https://github.com/lasaczka/darwinmenu/releases/download/v1.1/darwinmenu-v1.1-plasma6-5.plasmoid -o /tmp/darwinmenu.plasmoid
kpackagetool6 --type=Plasma/Applet --packageroot /usr/share/plasma/plasmoids -i /tmp/darwinmenu.plasmoid || true

# Plasma Drawer Plasmoid
curl -L https://github.com/p-connor/plasma-drawer/releases/download/v2.0.2/plasma-drawer-2.0.2.plasmoid -o /tmp/plasma-drawer.plasmoid
kpackagetool6 --type=Plasma/Applet --packageroot /usr/share/plasma/plasmoids -i /tmp/plasma-drawer.plasmoid || true

# KDE Control Station
git clone https://github.com/EliverLara/kde-control-station.git --depth=1 --branch plasma6 /tmp/kde-control-station
kpackagetool6 --type=Plasma/Applet --packageroot /usr/share/plasma/plasmoids -i /tmp/kde-control-station/package || true

# ==============================================================================
# 6. KWIN SCRIPTS
# ==============================================================================
# MACsimize6 KWin Script
curl -L https://github.com/Ubiquitine/MACsimize6/releases/download/v0.7.1/macsimize6-0.7.1.kwinscript -o /tmp/macsimize6.kwinscript
kpackagetool6 --type=KWin/Script --packageroot /usr/share/kwin/scripts -i /tmp/macsimize6.kwinscript || true

# ==============================================================================
# 8. COPR AND REPOSITORY TWEAKS
# ==============================================================================
systemctl enable --force sddm.service
sed -i 's/enabled=0/enabled=1/; s/gpgcheck=1/gpgcheck=0/g; /gpgkey=file:\/\//d' /etc/yum.repos.d/terra.repo
dnf install -y vicinae
sed -i 's/gpgcheck=1/gpgcheck=0/g; /gpgkey=file:\/\//d' /etc/yum.repos.d/terra-mesa.repo

# ==============================================================================
# 9. DEFAULT USER PROFILE CONFIGURATIONS (konsave)
# ==============================================================================
mkdir -p /tmp/konsave-venv
python3 -m venv /tmp/konsave-venv
/tmp/konsave-venv/bin/pip install konsave
/tmp/konsave-venv/bin/konsave -i /ctx/macOS-layout.knsv
/tmp/konsave-venv/bin/konsave -a macOS-layout
cp -r /root/.config/. /etc/skel/.config/
cp -r /root/.local/. /etc/skel/.local/ 2>/dev/null || true

# ==============================================================================
# 10. SYSTEM SERVICES CONFIGURATION
# ==============================================================================
systemctl enable podman.socket
