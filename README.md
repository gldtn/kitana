# Kitana

Personal Arch Linux bootstrap and post-install setup.

## What this does

- Installs core system, development, CLI, terminal, Hyprland ecosystem, and fonts.
- Installs desktop apps by category from separate scripts in `install/apps/`.
- Prompts for a browser choice and applies MIME defaults based on that selection.
- Creates web app launchers after browser selection.

## Install flow

1. Run `bootstrap.sh` on a fresh Arch install.
2. `install.sh` runs modular scripts in `install/`.
3. App categories run from `install/apps/*.sh`.

## App categories

- `install/apps/essentials.sh`
- `install/apps/editors.sh`
- `install/apps/productivity.sh`
- `install/apps/media.sh`
- `install/apps/files.sh`
- `install/apps/managers.sh`
- `install/apps/mimetypes.sh`
- `install/apps/webapps.sh`

## Desktop categories

- `install/desktop/cli.sh`
- `install/desktop/development.sh`
- `install/desktop/fonts.sh`
- `install/desktop/themes.sh`
- `install/desktop/hardening.sh`
- `install/desktop/hyprland.sh`
- `install/desktop/essentials.sh`
- `install/desktop/terminal.sh`

## Notes

- No display manager is installed or enabled (no SDDM path).
- `uwsm` is not installed by default.
- Hyprland config is intentionally not bundled right now; build `~/.config/hypr/` from scratch.
- Browser choice is stored in `~/.config/webapp-install.conf` and reused by:
  - `install/apps/mimetypes.sh`
  - `bin/webapp-install`
