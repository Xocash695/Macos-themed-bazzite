# MacOS-themed-bazzite
A custom image of Bazzite with a macOS theme pre-installed, featuring the MacTahoe GTK/KDE theme, Apple Plymouth boot splash, and more.

> **Disclaimer:** This project is in no way affiliated with, endorsed by, or associated with Apple Inc. macOS is a trademark of Apple Inc. This repository does not host any Apple assets or artifacts — it simply automates the download, installation, and configuration of third-party open-source themes and tools that are inspired by macOS. No ISO image is distributed publicly in this repository for legal reasons.

## About the Pre-built Package
The OCI image published to GHCR (`ghcr.io/xocash695/macos-themed-bazzite:latest`) is simply the automated output of running `build.sh` inside a container via GitHub Actions — the same result you would get if you built the image yourself from the source code in this repository. No assets are manually curated or hosted by this project; everything is fetched at build time from the original upstream sources listed in the Credits section. The published package exists purely as a convenience for existing users to receive updates without having to rebuild the image themselves.

## AI Disclosure
This project was created with the assistance of AI (Claude by Anthropic and Gemini by Google).

## What's Included
- MacTahoe GTK, Icon, and KDE theme
- MacTahoe SDDM login theme (Light and Dark variants, Light set by default)
- Apple Plymouth boot splash (regenerated on first boot)
- Zsh as default shell
- macOS-like KDE configuration (icons, plasma theme, GTK3/4 settings)
- MACsimize6 KWin script (moves maximized/fullscreen windows to separate virtual desktops, macOS-style)
- Nothing KDE Widgets (clock, battery, weather, media, and more)
- DarwinMenu and Plasma Drawer plasmoids
- KDE Control Station plasmoid
- tmux
- vicinae (via Terra repo)
- Podman socket enabled

### 🛠️ GitHub Actions Workflow changes: 

The `build-disk.yml` workflow has been updated to fix artifact download failures and optimize storage handling. Here is a summary of the changes:

* **Separated Matrix Artifacts:** Previously, both the `qcow2` and `anaconda-iso` build jobs uploaded their outputs to the same generic directory, causing them to conflict. The upload step now dynamically names the artifacts (`bazzite-qcow2` and `bazzite-anaconda-iso`) based on the build matrix.
* **Enabled Artifact Compression:** Removed the `compression-level: 0` flag. Allowing GitHub to compress the raw operating system images significantly reduces the final `.zip` size (from ~6.4 GB down to a manageable size), preventing browser gateway timeouts ($404$/$502$ errors) during download.
* **Fixed Artifact Retention:** Adjusted `retention-days` from `0` to `7` to ensure completed build images are safely stored and available for retrieval before being automatically purged.
* **Upgraded Upload Action:** Migrated the upload step to `actions/upload-artifact@v4` to natively support distinct matrix artifact naming conventions.

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
The `build-disk.yml` workflow creates an installable ISO. Trigger it manually from the Actions tab, selecting `amd64` as the platform. The ISO will be available as a downloadable artifact after the workflow completes. Note that the ISO is not distributed publicly in this repository for legal reasons.

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
- [DarwinMenu](https://github.com/lasaczka/darwinmenu) by lasaczka
- [Plasma Drawer](https://github.com/p-connor/plasma-drawer) by p-connor
- [KDE Control Station](https://github.com/EliverLara/kde-control-station) by EliverLara
- [Konsave](https://github.com/Prayag2/konsave) by Prayag2 — used to export and apply KDE profile configurations
- Built on [Bazzite](https://bazzite.gg/) by Universal Blue
