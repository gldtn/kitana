# Testing Notes

Temporary notes for clean-install testing and session handoff. Update this before wiping or reinstalling the machine, and delete or replace it with durable documentation once Kitana stabilizes.

## Current State

- 2026-06-21 handoff: current work is focused on live tuning Quickshell theme colors, especially `themes/*.jsonc` roles as seen through real shell controls.
- A temporary Quickshell theme preview exists at `config/quickshell/kitana/Theme/ThemePreview.qml` and is opened from a temporary top-bar item next to the screenshot button.
- Theme preview workflow:
  - `kitana-theme-preview open` opens the preview through IPC target `kitana-theme-preview`.
  - `kitana-theme-preview close` closes it.
  - `kitana-theme-preview` toggles it.
  - The preview header `Refresh` button runs `kitana-theme-quickshell <current-theme>` using the runtime theme slug from `Colors.theme.slug`.
- The preview is intentionally app-like while tuning:
  - `FloatingWindow`, title `Kitana Theme Preview`.
  - Fixed size `701x1360`.
  - Draggable from the preview title/header area via `startSystemMove()`.
  - Auto-floats itself on Hyprland with `hl.dsp.window.float({ action = "float" })` when the preview is the active toplevel.
- The preview samples currently include:
  - bar item and input side by side.
  - shortcut badge plus dismiss inactive/hover states on `Colors.bgPrimary`, `Colors.bgSecondary`, and `Colors.bgTertiary` surfaces.
  - quick tiles, slider row, detail-pane-style notification sample, palette role swatches, QML composition role swatches, and icon tone swatches.
- `Components/Controls/PanelRow.qml` currently has no QML usages after removing it from the preview. Keep it only if future panel code needs it.
- Temporary files and wiring added for the preview:
  - `bin/kitana-theme-preview`
  - `config/quickshell/kitana/Bar/Items/ThemePreview.qml`
  - `config/quickshell/kitana/Theme/ThemePreview.qml`
  - theme preview references threaded through `shell.qml`, `Bar/BarWindow.qml`, and `Bar/Sections/Right.qml`.
- This preview and bar item are temporary tuning aids. Remove or gate them once the six packaged themes are finalized.
- Kitana install flow is moving toward explicit `kitana-*` helper commands and targeted refresh/reinstall commands.
- Vicinae has been replaced by the Kitana Quickshell launcher.
- Dashboard media now uses a Quickshell MPRIS service with audio controls in an overlay.
- Quickshell lifecycle is managed by `kitana-quickshell`:
  - `kitana-quickshell`
  - `kitana-quickshell start`
  - `kitana-quickshell stop`
  - `kitana-quickshell restart`
  - `kitana-quickshell reload`
- SDDM is Kitana-owned through `default/sddm/` and refreshed by `kitana-refresh --sddm`.
- Optional/personal installs are explicit `kitana-install-*` commands, not installer flags.
- Private fonts now install from a configurable private Git repo instead of Dropbox.
- Arch USB media can be prepared with `bin/kitana-arch-usb`; the helper was added in `a232cf9` and pushed to `origin/master`.

## Recently Verified

- Theme preview validation on 2026-06-21:
  - `QT_HOST_PATH=/usr/lib/qt6 PATH="/usr/lib/qt6/bin:$PATH" /usr/lib/qt6/bin/qmllint --json - -I config/quickshell/kitana -I config/quickshell config/quickshell/kitana/Theme/ThemePreview.qml config/quickshell/kitana/Bar/Items/ThemePreview.qml config/quickshell/kitana/Bar/Sections/Right.qml config/quickshell/kitana/Bar/BarWindow.qml config/quickshell/kitana/shell.qml`
  - `bash -n bin/kitana-theme-preview`
  - `git diff --check`
  - `kitana-refresh --configs && kitana-quickshell reload && bin/kitana-theme-preview open`
  - `hyprctl clients -j | jq '.[] | select(.title == "Kitana Theme Preview") | {floating, size}'` returned `floating: true`, `size: [701, 1360]`.
- Install-focused `bash validate.sh` passes on the current machine.
- `SUPER+D` opens the Kitana Quickshell launcher.
- Launcher search, icons, hidden app filtering, and keyboard behavior were tested interactively.
- `kitana-quickshell start`, `stop`, `restart`, and `reload` were tested.
- `kitana-refresh --applications` installs hidden desktop overrides into `~/.local/share/applications`.
- Fresh install first-run visual state was verified:
  - SDDM shows the Kitana wallpaper on the first reboot after install.
  - Hyprland restores the seeded wallpaper and theme on first login.
  - Quickshell starts without the routine `Quickshell reload requested` notification.
- `bin/kitana-arch-usb --download-only`, `--help`, and `--list` were checked; `/dev/sda` was written successfully and reappeared as Arch install media labeled `ARCH_202606` with `ARCHISO_EFI`.
- Install-focused `bash validate.sh` passed after adding `kitana-arch-usb` to validation.

## Before Clean Install

- Commit or stash any local changes.
- Push the latest commits if this machine may be wiped.
- Run `git status --short` and ensure only intentional changes remain.
- Run `bash validate.sh` if the current install is still available and install health needs checking.
- Confirm the fresh machine pulls at least commit `a232cf9` before testing the new Arch USB helper or README instructions.
- Record any open issues in the section below.

## Open Issues

- None currently tracked.

## Fresh Machine Test Focus

- Run the normal bootstrap from the README and confirm the installer still completes from a clean Arch environment.
- After first reboot, verify SDDM, Hyprland, Quickshell, wallpaper/theme state, launcher bind, browser handlers, and install-focused `bash validate.sh`.
- If the Arch USB helper is tested again, prefer `kitana-arch-usb --list` first, then `--select --unmount`; confirm the selected device is a whole disk and not the internal NVMe.
- Plymouth is intentionally not configured yet. It is tracked in `TODO.md` as optional future boot polish with a migration/helper for existing installs.

## TODO

- See `TODO.md` for tracked follow-up work.

## Useful Commands

Use `bash validate.sh` for install/repair validation. During Quickshell iteration, prefer targeted `qmllint`, logs, and reload/restart checks.

```bash
git status --short
git log --oneline -10
bash validate.sh
qmllint --json - -I config/quickshell/kitana -I config/quickshell <files>
kitana-refresh --applications
kitana-refresh --configs
kitana-refresh --sddm
kitana-install-private-fonts --url https://github.com/gldtn/kitana-private-fonts.git
kitana-install-private-fonts --current
kitana-quickshell restart
bin/kitana-arch-usb --list
bin/kitana-arch-usb --download-only
bin/kitana-arch-usb --select --unmount
quickshell ipc -c kitana show
quickshell log -c kitana --no-color
```
