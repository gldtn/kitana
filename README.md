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
2. `install.sh` runs base system setup, then delegates to `install-desktop.sh` and `install-apps.sh`.
3. Desktop and app categories run from `install/desktop/*.sh` and `install/apps/*.sh`.

## Bootstrap

```bash
curl -fsSL https://raw.githubusercontent.com/gldtn/kitana/master/bootstrap.sh | bash
```

Bootstrap can also run a focused mode:

```bash
curl -fsSL https://raw.githubusercontent.com/gldtn/kitana/master/bootstrap.sh | bash -s -- desktop
curl -fsSL https://raw.githubusercontent.com/gldtn/kitana/master/bootstrap.sh | bash -s -- apps
curl -fsSL https://raw.githubusercontent.com/gldtn/kitana/master/bootstrap.sh | bash -s -- configs
```

- `full` runs the entire installer and is the default.
- `desktop` installs only desktop/Hyprland/system UI categories.
- `apps` installs only app categories, browser selection, MIME defaults, and webapps.
- `configs` deploys Kitana-managed config entrypoints without overwriting user overrides.

After install, validate the system with:

```bash
bash ~/.local/share/kitana/validate.sh
```

To rerun only app installation:

```bash
bash ~/.local/share/kitana/install-apps.sh
```

To rerun only desktop setup:

```bash
bash ~/.local/share/kitana/install-desktop.sh
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
- `install-desktop.sh` reruns only desktop categories and config deployment.

## Notes

- SDDM is installed and enabled in `install/desktop/essentials.sh`.
- `pixie-sddm-git` is included as the SDDM theme package.
- `uwsm` is not installed by default.
- SDDM starts the Hyprland session; `hyprlock` only locks an already-running session.
- Hyprland Lua defaults live in `~/.local/share/kitana/hypr`.
- The user Hypr config directory is a real directory at `~/.config/hypr`, not a symlink.
- The generated user entrypoint is `~/.config/hypr/hyprland.lua` and loads Kitana defaults.
- Override a default module by creating `~/.config/hypr/modules/<module>.lua` with the same module name.
- Scripts are linked individually into `~/.config/hypr/scripts` only when no user script already exists.
- `hypridle.conf` is copied to `~/.config/hypr/hypridle.conf` only if missing, so local edits are preserved.
- `hyprpaper.conf` is copied to `~/.config/hypr/hyprpaper.conf` only if missing, and wallpapers are linked from `~/.config/hypr/walls`.
- The Kitana Hyprland config entrypoint is `hypr/hyprland.lua`.
- Ghostty defaults live in `ghostty/`; `~/.config/ghostty/config` is copied only when missing or Kitana-managed, and themes are copied only when missing.
- On Hyprland 0.55+, `hyprland.lua` is loaded instead of `hyprland.conf` when present.
- Hyprlang config remains transitional for Hyprland and is expected to be dropped after 1-2 releases, but Hypr* tools may still use Hyprlang for their own configs.
- Browser choice is stored in `~/.config/webapp-install.conf` and reused by:
  - `install/apps/mimetypes.sh`
  - `bin/webapp-install`
  - `bin/webapp-launch`
