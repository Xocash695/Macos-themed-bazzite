# macOS-inspired Bazzite Desktop

A custom Bazzite-based OCI image featuring a desktop environment inspired by the design and user experience of macOS, including macOS-style KDE theming, window management tweaks, and curated open-source desktop enhancements.

> **Disclaimer:** This project is independent and is not affiliated with, endorsed by, or associated with Apple Inc. macOS is a trademark of Apple Inc.
> This repository does not include any Apple-owned assets or proprietary macOS components. It automates the download, installation, and configuration of third-party open-source themes and tools inspired by macOS design principles.
>
> The pre-built OCI image published to GHCR is generated automatically via GitHub Actions by running `build.sh`, which fetches all components from upstream open-source sources listed in the Credits section.
>
> A single Konsave profile (`macOS-layout.knsv`) is included to configure a default KDE layout for new users. This is applied automatically on first user creation via `/etc/skel`.

---

## AI Disclosure

This project was created with the assistance of AI tools (Claude by Anthropic and Gemini by Google).

---

## What's Included

* Zsh as default shell
* KDE configuration inspired by macOS desktop layout and workflow
* MACsimize6 KWin script (window behavior enhancements inspired by macOS-style desktop management)
* Nothing KDE Widgets (clock, battery, weather, media, and more)
* DarwinMenu and Plasma Drawer plasmoids
* KDE Control Station plasmoid
* tmux
* vicinae (via Terra repository)
* Podman socket enabled

---

## Community

If you have questions or issues, please use:

* https://universal-blue.discourse.group/
* https://discord.gg/WEu6BdFEtp
* https://github.com/bootc-dev/bootc/discussions

---

## How to Use

### Switch to This Image

From your bootc system, run:

```bash
sudo bootc switch ghcr.io/xocash695/macos-themed-bazzite:latest
```

Reboot after the command completes.

---

### First Boot

On first boot, system configuration services will apply desktop theming and regenerate the initramfs as needed. Full desktop configuration becomes active after reboot.

---

### New User Accounts

The macOS-inspired KDE layout (theme, panel configuration, and window behavior) is applied automatically to **new user accounts** via `/etc/skel`.

Create a new user after switching to this image to get the full experience.

---

## Building From Source

### Creating a Cosign Key

```bash
COSIGN_PASSWORD="" cosign generate-key-pair
```

Add the contents of `cosign.key` as a GitHub secret named `SIGNING_SECRET`.

---

### Building the Image

The image is built automatically via GitHub Actions on every push and published to:

```
ghcr.io/xocash695/macos-themed-bazzite:latest
```

---

### Building an ISO

The `build-disk.yml` workflow generates an installable ISO. It can be triggered manually from the Actions tab by selecting `amd64` as the target architecture. The resulting ISO is provided as a downloadable build artifact.

---

### 🛠️ GitHub Actions Workflow Optimizations

The `build-disk.yml` workflow has been updated to fix artifact download failures and optimize storage handling. Here is a summary of the changes:

* **Separated Matrix Artifacts:** Previously, both the `qcow2` and `anaconda-iso` build jobs uploaded their outputs to the same generic directory, causing them to conflict. The upload step now dynamically names the artifacts (`bazzite-qcow2` and `bazzite-anaconda-iso`) based on the build matrix.
* **Enabled Artifact Compression:** Removed the `compression-level: 0` flag. Allowing GitHub to compress the raw operating system images significantly reduces the final `.zip` size (from ~6.4 GB down to a manageable size), preventing browser gateway timeouts ($404$/$502$ errors) during download.
* **Fixed Artifact Retention:** Adjusted `retention-days` from `0` to `7` to ensure completed build images are safely stored and available for retrieval before being automatically purged.
* **Upgraded Upload Action:** Migrated the upload step to `actions/upload-artifact@v4` to natively support distinct matrix artifact naming conventions.

## Repository Contents

* **Containerfile** — defines the base image and build process
* **build.sh** — installs and configures desktop components
* **macOS-layout.knsv** — KDE layout profile for new users
* **build.yml** — GitHub Actions workflow for OCI image builds
* **build-disk.yml** — GitHub Actions workflow for ISO generation

---

## Credits

* https://github.com/Ubiquitine/MACsimize6 — MACsimize6
* https://github.com/jaxparrow07/nothing-kde-widgets — Nothing KDE Widgets
* https://github.com/lasaczka/darwinmenu — DarwinMenu
* https://github.com/p-connor/plasma-drawer — Plasma Drawer
* https://github.com/EliverLara/kde-control-station — KDE Control Station
* https://github.com/Prayag2/konsave — Konsave (KDE profile management)
* https://bazzite.gg/ — Bazzite by Universal Blue
