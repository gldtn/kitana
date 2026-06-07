# Kitana

Personal, opinionated Arch Linux bootstrap and post-install setup.

## What this does

- Installs core system, development, CLI, terminal, Hyprland ecosystem, and fonts.
- Installs Ioskeley Mono for editors and IoskeleyMonoTerm Nerd Font for terminals.
- Installs firmware support, CPU microcode, GPU diagnostics, and fwupd metadata refresh.
- Targets Hyprland 0.55+ with Lua-based config.
- Runs as an interactive personal installer.
- Prompts for a browser choice and applies MIME defaults based on that selection.
- Creates web app launchers after browser selection.

## Install flow

1. Run `bootstrap.sh` on a fresh Arch install.
2. `install.sh` runs base system setup, then delegates to `install-desktop.sh` and `install-apps.sh`.
3. Use targeted `kitana-reinstall` and `kitana-refresh` commands after install to repair individual parts.

## Bootstrap

Fresh full install:

```bash
curl -fsSL https://raw.githubusercontent.com/gldtn/kitana/master/bootstrap.sh | bash
```

The bootstrap runs the full installer. Use targeted `kitana-reinstall` and `kitana-refresh` commands after install to repair individual parts.

Tracked install failures are written to `~/.local/state/kitana/install-failures.log`.
The full install report is written to `~/.local/state/kitana/install-report.log`.

To repair or refresh Kitana pieces after install:

```bash
kitana-reinstall
kitana-reinstall --system
kitana-reinstall --desktop
kitana-reinstall --apps
kitana-reinstall --configs
kitana-refresh --applications
kitana-refresh --configs
kitana-refresh --sddm
kitana-refresh --wallpapers
```

Optional/personal installs are available as individual commands:

```bash
kitana-install-extras-crypto
kitana-install-extras-media
kitana-install-extras-wallpapers
kitana-install-private-fonts
```

To install private fonts from a private Git repo:

```bash
~/.local/share/kitana/bin/kitana-install-private-fonts --url https://github.com/gldtn/kitana-private-fonts.git
~/.local/share/kitana/bin/kitana-install-private-fonts
~/.local/share/kitana/bin/kitana-install-private-fonts --current
~/.local/share/kitana/bin/kitana-install-private-fonts --reset
```

The private font helper clones or updates the configured repo in `~/.local/state/kitana/private-fonts`, installs all `.otf`, `.ttf`, `.otc`, and `.ttc` files into `~/.local/share/fonts/kitana-private`, and refreshes fontconfig. The repo URL is stored in `~/.config/kitana/private-fonts.conf`.

To configure Git identity:

```bash
~/.local/share/kitana/bin/kitana-git-config
~/.local/share/kitana/bin/kitana-git-config --current
~/.local/share/kitana/bin/kitana-git-config --ensure
~/.local/share/kitana/bin/kitana-git-config --update
```

To inspect and update system firmware manually:

```bash
~/.local/share/kitana/bin/kitana-firmware bios
~/.local/share/kitana/bin/kitana-firmware devices
~/.local/share/kitana/bin/kitana-firmware updates
~/.local/share/kitana/bin/kitana-firmware update
```

Kitana installs `fwupd` and enables metadata refresh by default, but it never applies firmware updates automatically. `kitana-firmware update` shows the current BIOS/system information and asks for confirmation before running `fwupdmgr update`.

To install or change the browser used by web apps:

```bash
~/.local/share/kitana/bin/kitana-install-browser
~/.local/share/kitana/bin/kitana-install-browser --current
~/.local/share/kitana/bin/kitana-install-browser --apply-mime
~/.local/share/kitana/bin/kitana-install-browser --set-default
```

Browser choices include Brave, Brave Origin Beta, Chromium, Firefox, Google Chrome, Qutebrowser, and Zen Browser.

## Repository layout

- `applications/` is reserved for Kitana-managed desktop entry templates and launchers.
- `bin/` contains `kitana-*` helper commands and is prepended to `PATH` during install.
- `config/` contains user-facing config files copied into `~/.config` or `$HOME`.
- `default/` contains Kitana defaults and assets copied elsewhere by install helpers.
- `install/` contains install stages and shared install libraries.
- `themes/` contains Kitana theme definitions used by theme helpers.

## User Notes

- Kitana-managed config source lives in this repository; use refresh/reinstall commands to deploy changes.
- Customize Hyprland in `~/.config/hypr/custom/*.lua`; local custom modules load after Kitana defaults.
- Kitana user settings live in `~/.config/kitana/config`, including `KITANA_WALLPAPER_DIR`.
- Browser choice is stored in `~/.config/webapp-install.conf` and reused by Kitana web app helpers.
- Private font repo choice is stored in `~/.config/kitana/private-fonts.conf` and reused by `kitana-install-private-fonts`.

## Secrets And Keyring

Kitana installs `gnome-keyring` and `seahorse` as the default Secret Service compatibility layer. This gives desktop apps a standard place to store app tokens, OAuth sessions, and other non-browser secrets.

Kitana does not force GNOME Keyring as the preferred password manager, browser password store, or SSH agent. Browser flags intentionally avoid `--password-store=gnome-libsecret`, so users can choose browser sync, 1Password, Bitwarden, KeePassXC, or another password manager without Kitana overriding that choice.

## Thanks

Kitana is inspired by ideas and patterns from Omarchy and DankMaterial, adapted for Kitana's own structure and personal workflow.
