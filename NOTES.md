# Testing Notes

Temporary notes for clean-install testing and session handoff. Update this before wiping or reinstalling the machine, and delete or replace it with durable documentation once Kitana stabilizes.

## Current State

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
