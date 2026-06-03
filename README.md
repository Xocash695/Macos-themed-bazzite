# MacOS-themed-bazzite
A custom image of Bazzite with a macOS theme pre-installed, featuring the MacTahoe GTK/KDE theme, Apple Plymouth boot splash, and more.

## AI Disclosure
This project was created with the assistance of AI (Claude by Anthropic and Gemeni by Google)

## What's Included
- MacTahoe GTK, Icon, and KDE theme
- MacTahoe SDDM login theme (Light and Dark variants, Light set by default)
- Apple Plymouth boot splash (regenerated on first boot)
- Zsh as default shell
- macOS-like KDE configuration (icons, plasma theme, GTK3/4 settings)
- MACsimize6 KWin script (moves maximized/fullscreen windows to separate virtual desktops, macOS-style)
- Nothing KDE Widgets (clock, battery, weather, media, and more)
- kMenu plasmoid
- KDE Control Centre plasmoid
- tmux
- vicinae (via Terra repo)

## Community
If you have questions, try the following spaces:
- [Universal Blue Forums](https://universal-blue.discourse.group/)
- [Universal Blue Discord](https://discord.gg/WEu6BdFEtp)
- [bootc discussion forums](https://github.com/bootc-dev/bootc/discussions)

## How to Use
### Switch to This Image
From your bootc system, run:
```bash
sudo bootc switch ghcr.io/xocash695/macos-themed-bazzite:latest
```
Reboot after the command finishes.

### First Boot
On first boot, a systemd service will automatically regenerate the initramfs to apply the Apple Plymouth boot splash. You will see it on the second reboot.

### New User Accounts
The macOS-like KDE configuration (theme, icons, panel layout, KWin script) is applied automatically to **new user accounts** via `/etc/skel`. Create a new user after switching to this image to get the full experience.

## Building From Source
### Creating a Cosign Key
```bash
COSIGN_PASSWORD="" cosign generate-key-pair
```
Add the contents of `cosign.key` as a GitHub secret named `SIGNING_SECRET`.

### Building the Image
The image builds automatically via GitHub Actions on every push. It is published to `ghcr.io/xocash695/macos-themed-bazzite:latest`.

### Building an ISO
The `build-disk.yml` workflow creates an installable ISO. Trigger it manually from the Actions tab, selecting `amd64` as the platform. The ISO will be available as a downloadable artifact after the workflow completes.

## Repository Contents
- **Containerfile** — defines the base image and calls `build.sh`
- **build.sh** — installs and configures all themes and customizations
- **build.yml** — GitHub Actions workflow that builds and publishes the OCI image to GHCR
- **build-disk.yml** — GitHub Actions workflow that builds an installable ISO

## Credits
- [MacTahoe GTK Theme](https://github.com/vinceliuice/MacTahoe-gtk-theme) by vinceliuice
- [MacTahoe Icon Theme](https://github.com/vinceliuice/MacTahoe-icon-theme) by vinceliuice
- [MacTahoe KDE Theme](https://github.com/vinceliuice/MacTahoe-kde) by vinceliuice
- [Apple Mac Plymouth](https://github.com/Msouza91/apple-mac-plymouth) by Msouza91
- [MACsimize6](https://github.com/Ubiquitine/MACsimize6) by Ubiquitine
- [Nothing KDE Widgets](https://github.com/jaxparrow07/nothing-kde-widgets) by jaxparrow07
- [kMenu](https://github.com/51n7/kMenu) by 51n7
- [KDE Control Centre](https://github.com/Prayag2/kde_controlcentre) by Prayag2
- Built on [Bazzite](https://bazzite.gg/) by Universal Blue
