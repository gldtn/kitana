# Kitana

Personal Arch Linux bootstrap and post-install setup.

## What this does

- Installs core system, development, CLI, terminal, Hyprland ecosystem, and fonts.
- Targets Hyprland 0.55+ with Lua-based config.
- Installs desktop apps by category from separate scripts in `install/apps/`.
- Prompts for a browser choice and applies MIME defaults based on that selection.
- Creates web app launchers after browser selection.

## Install flow

1. Run `bootstrap.sh` on a fresh Arch install.
2. `install.sh` runs modular scripts in `install/`.
3. App categories run from `install/apps/*.sh`.

## Bootstrap

```bash
curl -fsSL https://raw.githubusercontent.com/gldtn/kitana/master/bootstrap.sh | bash
```

After install, validate the system with:

```bash
bash ~/.local/share/kitana/validate.sh
```

To rerun only app installation:

```bash
bash ~/.local/share/kitana/install-apps.sh
```

## App categories

- `install/apps/ai.sh`
- `install/apps/communication.sh`
- `install/apps/crypto.sh`
- `install/apps/essentials.sh`
- `install/apps/editors.sh`
- `install/apps/productivity.sh`
- `install/apps/media.sh`
- `install/apps/files.sh`
- `install/apps/managers.sh`
- `install/apps/mimetypes.sh`
- `install/apps/webapps.sh`
- `install-apps.sh` reruns only app categories, browser selection, MIME defaults, and webapps.

## Desktop categories

- `install/desktop/cli.sh`
- `install/desktop/configs.sh`
- `install/desktop/development.sh`
- `install/desktop/fonts.sh`
- `install/desktop/themes.sh`
- `install/desktop/hardening.sh`
- `install/desktop/hyprland.sh`
- `install/desktop/essentials.sh`
- `install/desktop/terminal.sh`

## Notes

- SDDM is installed and enabled in `install/desktop/essentials.sh`.
- `pixie-sddm-git` is included as the SDDM theme package.
- `uwsm` is not installed by default.
- SDDM starts the Hyprland session; `hyprlock` only locks an already-running session.
- Hyprland Lua config is linked from `hypr/` to `~/.config/hypr` during install.
- The Hyprland config entrypoint is `hypr/hyprland.lua`.
- On Hyprland 0.55+, `hyprland.lua` is loaded instead of `hyprland.conf` when present.
- Hyprlang config remains transitional for Hyprland and is expected to be dropped after 1-2 releases, but Hypr* tools may still use Hyprlang for their own configs.
- Browser choice is stored in `~/.config/webapp-install.conf` and reused by:
  - `install/apps/mimetypes.sh`
  - `bin/webapp-install`
  - `bin/webapp-launch`
