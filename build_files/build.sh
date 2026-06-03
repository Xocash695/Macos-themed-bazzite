#!/bin/bash
set -ouex pipefail

# ==============================================================================
# 1. CORE PACKAGES & DEPENDENCIES
# ==============================================================================
dnf install -y sassc zsh plymouth-plugin-script sddm sddm-kcm tmux jq

# Configure default system shell parameters
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

# Install MacTahoe Cursors (Fixed manual loop deployment)
CURSOR_DIR="/tmp/tahoe-icons/cursors"
INDEX_FILE="${CURSOR_DIR}/src/cursorSVG"

if [ -d "$CURSOR_DIR" ] && [ -f "$INDEX_FILE" ]; then
    for color in "" "-dark"; do
        # Handle the base theme directory name format
        THEME_DIR="/usr/share/icons/MacTahoe${color}-cursors"
        rm -rf "$THEME_DIR"
        mkdir -p "$THEME_DIR"

        # Copy compiled bin mappings
        cp -r "${CURSOR_DIR}/dist${color}"/* "${THEME_DIR}/"

        # Copy global configuration components
        cp -rf "${CURSOR_DIR}/src/scalable" "${THEME_DIR}/cursors_scalable"

        # Parse the cursor indexing map to assign custom vectors properly
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
# Nothing KDE Widgets (Fixed dynamic ID mapping via jq)
git clone https://github.com/jaxparrow07/nothing-kde-widgets.git --depth=1 /tmp/nothing-kde-widgets
cd /tmp/nothing-kde-widgets
for widget_dir in packages/*/; do
    if [ -d "$widget_dir" ] && [ -f "${widget_dir}metadata.json" ]; then
        # Read the exact internal ID required by Plasma
        WIDGET_ID=$(jq -r '.KPlugin.Id' "${widget_dir}metadata.json")
        if [ "$WIDGET_ID" != "null" ] && [ -n "$WIDGET_ID" ]; then
            mkdir -p "/usr/share/plasma/plasmoids/${WIDGET_ID}"
            cp -r "${widget_dir}"* "/usr/share/plasma/plasmoids/${WIDGET_ID}/"
        fi
    fi
done

# Extract fonts included in the widget package
mkdir -p /usr/share/fonts/truetype/nothing
find /tmp/nothing-kde-widgets/ -name "*.ttf" -o -name "*.otf" -exec cp {} /usr/share/fonts/truetype/nothing/ \;
fc-cache -f &>/dev/null || true

# DarwinMenu Plasmoid (Fixed name mapping to org.latcardi.darwinmenu)
git clone https://github.com/lasaczka/darwinmenu.git --depth=1 /tmp/darwinmenu
mkdir -p /usr/share/plasma/plasmoids/org.latcardi.darwinmenu
cp -r /tmp/darwinmenu/package/* /usr/share/plasma/plasmoids/org.latcardi.darwinmenu/

# Plasma Drawer Plasmoid (Fixed Root Directory Mapping)
git clone https://github.com/p-connor/plasma-drawer.git --depth=1 /tmp/plasma-drawer
rm -rf /usr/share/plasma/plasmoids/org.kde.plasma.drawer
cp -r /tmp/plasma-drawer /usr/share/plasma/plasmoids/org.kde.plasma.drawer
rm -rf /usr/share/plasma/plasmoids/org.kde.plasma.drawer/.git

# KDE Control Centre Plasmoid
git clone https://github.com/Prayag2/kde_controlcentre.git --depth=1 /tmp/kde-controlcentre
rm -rf /usr/share/plasma/plasmoids/com.github.prayag2.controlcentre
cp -r /tmp/kde-controlcentre/package /usr/share/plasma/plasmoids/com.github.prayag2.controlcentre
# ==============================================================================
# 6. KWIN SCRIPTS
# ==============================================================================
# MACsimize6 KWin Script
git clone https://github.com/Ubiquitine/MACsimize6.git --depth=1 /tmp/macsimize6
mkdir -p /usr/share/kwin/scripts/MACsimize6
cp -r /tmp/macsimize6/contents /usr/share/kwin/scripts/MACsimize6/
cp /tmp/macsimize6/metadata.json /usr/share/kwin/scripts/MACsimize6/

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

# ==============================================================================
# 9. GLOBAL DEFAULT USER PROFILE CONFIGURATIONS (etc/skel)
# ==============================================================================
mkdir -p /etc/skel/.config/gtk-3.0
mkdir -p /etc/skel/.config/gtk-4.0

printf '[Icons]\nTheme=MacTahoe-light\n\n[KDE]\nLookAndFeelPackage=com.github.vinceliuice.MacTahoeLight\n' > /etc/skel/.config/kdeglobals
printf '[Theme]\nname=MacTahoe-Light\n' > /etc/skel/.config/plasmarc
printf '[Settings]\ngtk-theme-name=MacTahoe-Light\ngtk-icon-theme-name=MacTahoe-light\n' > /etc/skel/.config/gtk-3.0/settings.ini
printf '[Settings]\ngtk-theme-name=MacTahoe-Light\ngtk-icon-theme-name=MacTahoe-light\n' > /etc/skel/.config/gtk-4.0/settings.ini
printf '[Plugins]\nMACsimize6Enabled=true\n' >> /etc/skel/.config/kwinrc

# ==============================================================================
# 10. SYSTEM SERVICES CONFIGURATION
# ==============================================================================
systemctl enable podman.socket
