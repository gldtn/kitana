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

## Recently Verified

- `bash validate.sh` passes on the current machine.
- `SUPER+D` opens the Kitana Quickshell launcher.
- Launcher search, icons, hidden app filtering, and keyboard behavior were tested interactively.
- `kitana-quickshell start`, `stop`, `restart`, and `reload` were tested.
- `kitana-refresh --applications` installs hidden desktop overrides into `~/.local/share/applications`.
- Fresh install first-run visual state was verified:
  - SDDM shows the Kitana wallpaper on the first reboot after install.
  - Hyprland restores the seeded wallpaper and theme on first login.
  - Quickshell starts without the routine `Quickshell reload requested` notification.

## Before Clean Install

- Commit or stash any local changes.
- Push the latest commits if this machine may be wiped.
- Run `git status --short` and ensure only intentional changes remain.
- Run `bash validate.sh` if the current install is still available.
- Record any open issues in the section below.

## Open Issues

- None currently tracked.

## TODO

- Design a Kitana first-run stage, likely triggered once from Hyprland autostart with per-step markers under `~/.local/state/kitana/first-run/`. Candidate first-run tasks:
  - Apply live GNOME/GTK settings (`Adwaita-dark`, `Adwaita`, `prefer-dark`) after first login.
  - Show a welcome/keybinding notification once Quickshell/notifications are actually running.
  - Configure optional hardening like `ufw` explicitly as a first-run/user-visible choice instead of silently enabling it during reinstall.
  - Handle user-session services that need a running session, such as future battery monitoring or OSD services.
  - Keep package installation, config file deployment, SDDM setup, firmware metadata refresh, and hardware package detection in install/reinstall stages rather than first-run.
- Revisit real CAVA integration for the dashboard media visualizer. Current bars are synthetic; a later pass should add a small `cava` service/process parser with graceful fallback.
- Revisit theme-specific blur coordination between Hyprland and Quickshell. Hyprland now has blur profiles, but Quickshell still owns separate alpha/color tokens in `Colors.qml`; later theme generation could set both together.
- Consider Bitwarden lock separately after confirming the right command/session behavior.

## Useful Commands

```bash
git status --short
git log --oneline -10
bash validate.sh
kitana-refresh --applications
kitana-refresh --configs
kitana-refresh --sddm
kitana-install-private-fonts --url https://github.com/gldtn/kitana-private-fonts.git
kitana-install-private-fonts --current
kitana-quickshell restart
quickshell ipc -c kitana show
quickshell log -c kitana --no-color
```
