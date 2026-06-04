# Kitana

Personal, opinionated Arch Linux bootstrap and post-install setup.

## What this does

- Installs core system, development, CLI, terminal, Hyprland ecosystem, and fonts.
- Targets Hyprland 0.55+ with Lua-based config.
- Runs as an interactive personal installer.
- Prompts for a browser choice and applies MIME defaults based on that selection.
- Creates web app launchers after browser selection.

## Install flow

1. Run `bootstrap.sh` on a fresh Arch install.
2. `install.sh` runs base system setup, then delegates to `install-desktop.sh` and `install-apps.sh`.
3. Use `kitana-reinstall-*` and `kitana-refresh-*` commands after install to repair individual parts.

## Bootstrap

Fresh full install:

```bash
curl -fsSL https://raw.githubusercontent.com/gldtn/kitana/master/bootstrap.sh | bash
```

The bootstrap runs the full installer. Use the `kitana-reinstall-*` and `kitana-refresh-*` commands after install to repair individual parts.

Tracked install failures are written to `~/.local/state/kitana/install-failures.log`.
The full install report is written to `~/.local/state/kitana/install-report.log`.

To repair or refresh Kitana pieces after install:

```bash
kitana-reinstall
kitana-reinstall-apps
kitana-reinstall-desktop
kitana-reinstall-configs
kitana-refresh-applications
kitana-refresh-configs
kitana-refresh-sddm
kitana-refresh-wallpapers
```

Optional/personal installs are available as individual commands:

```bash
kitana-install-extras-crypto
kitana-install-extras-media
kitana-install-extras-wallpapers
```

To configure Git identity:

```bash
~/.local/share/kitana/bin/kitana-git-config
~/.local/share/kitana/bin/kitana-git-config --current
~/.local/share/kitana/bin/kitana-git-config --ensure
~/.local/share/kitana/bin/kitana-git-config --update
```

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

## Thanks

Kitana is inspired by ideas and patterns from Omarchy and DankMaterial, adapted for Kitana's own structure and personal workflow.
