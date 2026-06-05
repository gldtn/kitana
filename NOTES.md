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
- SDDM is Kitana-owned through `default/sddm/` and refreshed by `kitana-refresh-sddm`.
- Optional/personal installs are explicit `kitana-install-*` commands, not installer flags.

## Recently Verified

- `bash validate.sh` passes on the current machine.
- `SUPER+D` opens the Kitana Quickshell launcher.
- Launcher search, icons, hidden app filtering, and keyboard behavior were tested interactively.
- `kitana-quickshell start`, `stop`, `restart`, and `reload` were tested.
- `kitana-refresh-applications` installs hidden desktop overrides into `~/.local/share/applications`.

## Before Clean Install

- Commit or stash any local changes.
- Push the latest commits if this machine may be wiped.
- Run `git status --short` and ensure only intentional changes remain.
- Run `bash validate.sh` if the current install is still available.
- Record any open issues in the section below.

## Open Issues

- Confirm on the next fresh install that first-run visual state is fixed, then remove this temporary note:
  - SDDM should show the Kitana wallpaper on the first reboot after install.
  - Hyprland should restore the seeded wallpaper and theme on first login.
  - Quickshell should start without the routine `Quickshell reload requested` notification.
  - Related fixes seed `~/.config/kitana/wallpaper`, `current-wallpaper`, and `theme` during config install, give `kitana-refresh-sddm` a bundled wallpaper fallback, and start Quickshell with `kitana-quickshell start` from Hyprland autostart.
- Revisit real CAVA integration for the dashboard media visualizer. Current bars are synthetic; a later pass should add a small `cava` service/process parser with graceful fallback.

## Useful Commands

```bash
git status --short
git log --oneline -10
bash validate.sh
kitana-refresh-applications
kitana-refresh-configs
kitana-refresh-sddm
kitana-quickshell restart
quickshell ipc -c kitana show
quickshell log -c kitana --no-color
```
