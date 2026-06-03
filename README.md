# Kitana

Personal, opinionated Arch Linux bootstrap and post-install setup.

## What this does

- Installs core system, development, CLI, terminal, Hyprland ecosystem, and fonts.
- Targets Hyprland 0.55+ with Lua-based config.
- Installs desktop apps by category from separate scripts in `install/apps/`.
- Runs as an interactive personal installer.
- Prompts for a browser choice and applies MIME defaults based on that selection.
- Creates web app launchers after browser selection.

## Install flow

1. Run `bootstrap.sh` on a fresh Arch install.
2. `install.sh` runs base system setup, then delegates to `install-desktop.sh` and `install-apps.sh`.
3. Desktop and app categories run from `install/desktop/*.sh` and `install/apps/*.sh`.

## Bootstrap

Fresh full install:

```bash
curl -fsSL https://raw.githubusercontent.com/gldtn/kitana/master/bootstrap.sh | bash
```

The bootstrap runs the full installer. Use the `kitana-reinstall-*` and `kitana-refresh-*` commands after install to repair individual parts.

Tracked install failures are written to `~/.local/state/kitana/install-failures.log`.
The full install report is written to `~/.local/state/kitana/install-report.log`.

After install, validate the system with:

```bash
bash ~/.local/share/kitana/validate.sh
```

To rerun only app installation:

```bash
bash ~/.local/share/kitana/install-apps.sh
```

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
kitana-install-1password
kitana-install-dropbox
kitana-install-extras-crypto
kitana-install-extras-media
kitana-install-ghostty-nightly
kitana-install-nvim-gldtn
kitana-install-private-fonts
kitana-install-wallpapers
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

To rerun only desktop setup:

```bash
bash ~/.local/share/kitana/install-desktop.sh
```

## App categories

- `install/apps/ai.sh`
- `install/apps/communication.sh`
- `install/apps/essentials.sh`
- `install/apps/editors.sh`
- `install/apps/productivity.sh`
- `install/apps/media.sh`
- `install/apps/files.sh`
- `install/apps/managers.sh`
- `install/apps/mimetypes.sh`
- `install/apps/webapps.sh`
- `install-apps.sh` reruns only app categories, browser selection, MIME defaults, and webapps.

## Repository layout

- `applications/` is reserved for Kitana-managed desktop entry templates and launchers.
- `bin/` contains `kitana-*` helper commands and is prepended to `PATH` during install.
- `config/` contains user-facing config files copied into `~/.config` or `$HOME`.
- `default/` contains Kitana defaults and assets copied elsewhere by install helpers.
- `install/` contains install stages and shared install libraries.
- `themes/` contains Kitana theme definitions used by theme helpers.

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

## Login

- `install/login/sddm.sh` installs SDDM, refreshes the Kitana SDDM theme, and enables `sddm.service`.
- `bin/kitana-refresh-sddm` refreshes `/usr/share/sddm/hyprland.lua`, `/usr/share/sddm/themes/kitana`, `/etc/sddm.conf.d/10-wayland.conf`, and `/etc/sddm.conf.d/20-theme.conf`.
- Test the SDDM theme with `sddm-greeter --test-mode --theme /usr/share/sddm/themes/kitana`.

## Notes

- SDDM is installed and enabled in `install/login/sddm.sh`.
- The Kitana SDDM theme source lives in `default/sddm/theme` and is installed to `/usr/share/sddm/themes/kitana`.
- The SDDM greeter compositor uses `/usr/share/sddm/hyprland.lua` through `/etc/sddm.conf.d/10-wayland.conf`.
- `uwsm` is not installed by default.
- SDDM starts the Hyprland session; `hyprlock` only locks an already-running session.
- `config/` contains Kitana-managed user-facing entrypoints copied into `~/.config` or `$HOME`.
- `default/` contains Kitana defaults and assets; do not edit these directly.
- Hyprland Lua defaults live in `~/.local/share/kitana/default/hypr`.
- The user Hypr config directory is a real directory at `~/.config/hypr`, not a symlink.
- The managed user entrypoint is `~/.config/hypr/hyprland.lua` and loads Kitana defaults first.
- Customize Hyprland in `~/.config/hypr/custom/*.lua`; these files load after Kitana defaults.
- Scripts are linked individually into `~/.config/hypr/scripts` only when no user script already exists.
- `hypridle.conf` is copied to `~/.config/hypr/hypridle.conf` only if missing, so local edits are preserved.
- Kitana user settings live in `~/.config/kitana/config`.
- Wallpapers default to `~/.config/kitana/wallpapers`; override with `KITANA_WALLPAPER_DIR` in `~/.config/kitana/config`.
- Bundled wallpapers live in `~/.local/share/kitana/default/wallpapers`.
- Personal extras are installed with explicit `kitana-install-*` commands instead of installer flags.
- `hyprpaper.conf` is copied to `~/.config/hypr/hyprpaper.conf` only if missing; wallpaper selection is managed by `bin/kitana-wallpaper`.
- Bash defaults live in `default/bash`; customize Bash in `~/.config/bash/custom/*.bash`.
- Starship config is copied to `~/.config/starship/starship.toml` only when missing or Kitana-managed.
- Ghostty defaults live in `default/ghostty`; `~/.config/ghostty/config` is copied only when missing or Kitana-managed, and themes are copied only when missing.
- On Hyprland 0.55+, `hyprland.lua` is loaded instead of `hyprland.conf` when present.
- Hyprlang config remains transitional for Hyprland and is expected to be dropped after 1-2 releases, but Hypr* tools may still use Hyprlang for their own configs.
- Browser choice is stored in `~/.config/webapp-install.conf` and reused by:
  - `install/apps/mimetypes.sh`
  - `bin/kitana-webapp-install`
  - `bin/kitana-webapp-launch`
- Web app desktop entries call `bin/kitana-webapp-launch`, so changing the Kitana browser config updates future web app launches without rewriting each desktop file.
