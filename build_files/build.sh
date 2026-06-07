#!/bin/bash
set -ouex pipefail

# ==============================================================================
# 1. CORE PACKAGES & DEPENDENCIES
# ==============================================================================
dnf install -y sassc zsh plymouth-plugin-script sddm sddm-kcm tmux jq kpackagetool6

# Configure default system shell parameters
chmod g-w /usr/local/share/zsh/site-functions
chmod g-w /usr/local/share/zsh
useradd -D -s /bin/zsh
sed -i 's|SHELL=.*|SHELL=/bin/zsh|' /etc/default/useradd

# ==============================================================================
# 2. GLOBAL DIRECTORY INITIALIZATION
# ==============================================================================
mkdir -p /usr/share/themes
mkdir -p /usr/share/icons
mkdir -p /usr/share/sddm/themes
mkdir -p /usr/share/plasma/plasmoids

# ==============================================================================
# 3. MACTAHOE DESKTOP STYLING (GTK, ICONS, & PLASMA CORE)
# ==============================================================================
# MacTahoe GTK Theme
git clone https://github.com/vinceliuice/MacTahoe-gtk-theme.git --depth=1 /tmp/tahoe-gtk
cd /tmp/tahoe-gtk
./install.sh --silent-mode 2>&1 | tail -50 || true

# MacTahoe Icon Theme
git clone https://github.com/vinceliuice/MacTahoe-icon-theme.git --depth=1 /tmp/tahoe-icons
cd /tmp/tahoe-icons
./install.sh -d /usr/share/icons

# Install MacTahoe Cursors
CURSOR_DIR="/tmp/tahoe-icons/cursors"
INDEX_FILE="${CURSOR_DIR}/src/cursorSVG"

if [ -d "$CURSOR_DIR" ] && [ -f "$INDEX_FILE" ]; then
    for color in "" "-dark"; do
        THEME_DIR="/usr/share/icons/MacTahoe${color}-cursors"
        rm -rf "$THEME_DIR"
        mkdir -p "$THEME_DIR"
        cp -r "${CURSOR_DIR}/dist${color}"/* "${THEME_DIR}/"
        cp -rf "${CURSOR_DIR}/src/scalable" "${THEME_DIR}/cursors_scalable"
        for svgid in $(cat "$INDEX_FILE"); do
            cp -rf "${CURSOR_DIR}/src/svg${color}/${svgid}.svg" "${THEME_DIR}/cursors_scalable/${svgid}"
            cp -rf "${CURSOR_DIR}/src/svg${color}/progress"*".svg" "${THEME_DIR}/cursors_scalable/progress"
            cp -rf "${CURSOR_DIR}/src/svg${color}/wait"*".svg" "${THEME_DIR}/cursors_scalable/wait"
        done
    done
fi

# MacTahoe KDE Theme (Global Engine Styles)
git clone https://github.com/vinceliuice/MacTahoe-kde.git --depth=1 /tmp/tahoe-kde
cd /tmp/tahoe-kde
./install.sh

# ==============================================================================
# 4. NATIVE SDDM SYSTEM LOGIN THEME DEPLOYMENT
# ==============================================================================
SDDM_THEME_DIR="/usr/share/sddm/themes"
DESK_VERSION="6.0"

# Deploy Light Variant
rm -rf "${SDDM_THEME_DIR}/MacTahoe-Light"
cp -r "/tmp/tahoe-kde/sddm/MacTahoe-${DESK_VERSION}" "${SDDM_THEME_DIR}/MacTahoe-Light"
cp -r "/tmp/tahoe-kde/sddm/images/Background-Light.jpeg" "${SDDM_THEME_DIR}/MacTahoe-Light/Background.jpeg"
cp -r "/tmp/tahoe-kde/sddm/images/Preview-Light.jpeg" "${SDDM_THEME_DIR}/MacTahoe-Light/Preview.jpeg"
sed -i 's/Name=MacTahoe/Name=MacTahoe-Light/g' "${SDDM_THEME_DIR}/MacTahoe-Light/metadata.desktop"
sed -i 's/Theme-Id=MacTahoe/Theme-Id=MacTahoe-Light/g' "${SDDM_THEME_DIR}/MacTahoe-Light/metadata.desktop"
sed -i 's/MacTahoe/MacTahoe-Light/g' "${SDDM_THEME_DIR}/MacTahoe-Light/Main.qml"

# Deploy Dark Variant
rm -rf "${SDDM_THEME_DIR}/MacTahoe-Dark"
cp -r "/tmp/tahoe-kde/sddm/MacTahoe-${DESK_VERSION}" "${SDDM_THEME_DIR}/MacTahoe-Dark"
cp -r "/tmp/tahoe-kde/sddm/images/Background-Dark.jpeg" "${SDDM_THEME_DIR}/MacTahoe-Dark/Background.jpeg"
cp -r "/tmp/tahoe-kde/sddm/images/Preview-Dark.jpeg" "${SDDM_THEME_DIR}/MacTahoe-Dark/Preview.jpeg"
sed -i 's/Name=MacTahoe/Name=MacTahoe-Dark/g' "${SDDM_THEME_DIR}/MacTahoe-Dark/metadata.desktop"
sed -i 's/Theme-Id=MacTahoe/Theme-Id=MacTahoe-Dark/g' "${SDDM_THEME_DIR}/MacTahoe-Dark/metadata.desktop"
sed -i 's/MacTahoe/MacTahoe-Dark/g' "${SDDM_THEME_DIR}/MacTahoe-Dark/Main.qml"

# Force SDDM to load MacTahoe-Light globally on system boot
mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=MacTahoe-Light\n' > /etc/sddm.conf.d/theme.conf

# ==============================================================================
# 5. PLASMOIDS & EXTENSION WIDGETS DEPLOYMENT
# ==============================================================================
# Extract fonts included in the widget package
#
# Nothing KDE Widgets
# Nothing KDE Widgets
git clone https://github.com/jaxparrow07/nothing-kde-widgets.git --depth=1 /tmp/nothing-kde-widgets
cd /tmp/nothing-kde-widgets
for widget_dir in packages/*/; do
    if [ -d "$widget_dir" ] && [ -f "${widget_dir}metadata.json" ]; then
        kpackagetool6 --type=Plasma/Applet --packageroot /usr/share/plasma/plasmoids -i "${widget_dir%/}" || true
    fi
done

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
# MACsimize6 KWin Script
curl -L https://github.com/Ubiquitine/MACsimize6/releases/download/v0.7.1/macsimize6-0.7.1.kwinscript -o /tmp/macsimize6.kwinscript
kpackagetool6 --type=KWin/Script --packageroot /usr/share/kwin/scripts -i /tmp/macsimize6.kwinscript || true
# ==============================================================================
# 7. PLYMOUTH BOOT SPLASH GRAPHICS
# ==============================================================================
git clone https://github.com/Msouza91/apple-mac-plymouth.git /tmp/apple-plymouth
PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/apple-mac-plymouth"
mkdir -p "$PLYMOUTH_THEME_DIR"
cp -r /tmp/apple-plymouth/* "$PLYMOUTH_THEME_DIR/"

mkdir -p /etc/plymouth
printf '[Daemon]\nTheme=apple-mac-plymouth\nShowDelay=0\n' > /etc/plymouth/plymouthd.conf
if [ -f /usr/share/plymouth/plymouthd.defaults ]; then
    sed -i 's/^Theme=.*/Theme=apple-mac-plymouth/' /usr/share/plymouth/plymouthd.defaults
fi

printf '[Unit]\nDescription=Set Plymouth theme on first boot\nConditionPathExists=!/var/lib/plymouth-theme-set\nAfter=local-fs.target\n\n[Service]\nType=oneshot\nExecStart=/usr/sbin/plymouth-set-default-theme -R apple-mac-plymouth\nExecStartPost=/usr/bin/touch /var/lib/plymouth-theme-set\nRemainAfterExit=yes\n\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/plymouth-theme-set.service
systemctl enable plymouth-theme-set.service

# ==============================================================================
# 8. COPR AND REPOSITORY TWEAKS
# ==============================================================================
systemctl enable --force sddm.service
sed -i 's/enabled=0/enabled=1/; s/gpgcheck=1/gpgcheck=0/g; /gpgkey=file:\/\//d' /etc/yum.repos.d/terra.repo
dnf install -y vicinae
sed -i 's/gpgcheck=1/gpgcheck=0/g; /gpgkey=file:\/\//d' /etc/yum.repos.d/terra-mesa.repo
## set my default configs:
pip3 install konsave --break-system-packages
konsave -i /ctx/macOS-layout.knsv
konsave -a macOS-layout -o /etc/skel

systemctl enable podman.socket
