# Kitana Handoff

This note is for continuing the opencode session from another machine after pulling this repo.

## Current State

- Repo path on test PC: `/home/gldtn/.local/share/kitana`
- Branch: `master`
- Last known base before this handoff: `247d129 Split wallpaper extras and add optional nvim config`
- This handoff commit contains the install hardening work and this note.
- Validation passed on the test PC after the changes.

## Current Goal

Prepare Kitana for fresh unattended reinstall testing on the live/test PC while keeping enough failure tracking to recover manually if an AUR package or optional component fails.

The test PC will be used for destructive/fresh install testing. Continue code edits and opencode work from the main PC after pulling this repo.

## What Changed

- Added shared installer helpers in `install/lib/install.sh`.
- Added install report/failure tracking under `~/.local/state/kitana/`.
- Added final install summaries to:
  - `install.sh`
  - `install-desktop.sh`
  - `install-apps.sh`
- Added unattended controls:
  - `KITANA_UNATTENDED=1`
  - `KITANA_BROWSER=brave|chromium|firefox|google-chrome-stable|qutebrowser|zen-browser`
  - `KITANA_GIT_NAME`
  - `KITANA_GIT_EMAIL`
  - `KITANA_EDGE=1`
- Added safe sudoers wheel helper in `install/preflight/sudoers.sh` using `visudo -cf` validation.
- Added Git identity setup in `install/apps/git-config.sh`.
- Made `bin/install-browser` unattended-aware.
- Made `bin/webapp-install` avoid browser prompts when unattended.
- Converted package install loops to shared tracked helpers.
- Required packages fail fast and log repair info.
- Optional/AUR-heavy packages log failures and continue.
- Added stable-default/edge-opt-in policy:
  - default editor package: `neovim`
  - edge editor package: `neovim-git`, fallback `neovim`
  - default terminal package: `ghostty`
  - edge terminal package: `ghostty-nightly-bin`, fallback `ghostty`
- Made `matugen-bin` and `pixie-sddm-git` optional in theme install.
- Updated `validate.sh` to accept either `ghostty` or `ghostty-nightly-bin` and no longer require optional `pixie-sddm-git`.
- Updated `README.md` with unattended examples.

## Important Files

- `install/lib/install.sh`: shared install helpers and failure logging.
- `install/lib/extras.sh`: optional extras helper, now sources install helper safely.
- `install.sh`: full install orchestration, unattended reboot skip, summary output.
- `install-desktop.sh`: desktop install orchestration and summary output.
- `install-apps.sh`: app install orchestration, browser install, Git config, summary output.
- `install/preflight.sh`: system update, required preflight packages, `yay` bootstrap with tracked failures.
- `install/preflight/sudoers.sh`: safe sudoers wheel helper.
- `install/apps/git-config.sh`: Git identity setup.
- `bin/install-browser`: unattended browser selection/install.
- `bin/webapp-install`: webapp launcher helper, unattended browser fallback.
- `validate.sh`: validation adjusted for stable/default package policy.

## Validation Run On Test PC

These passed before handoff:

```bash
bash -n bootstrap.sh install.sh install-desktop.sh install-apps.sh install/preflight.sh install/preflight/sudoers.sh install/lib/install.sh install/lib/extras.sh install/apps/git-config.sh bin/install-browser bin/webapp-install validate.sh
git diff --check
bash validate.sh
```

## Pull On Main PC

```bash
cd ~/.local/share/kitana
git pull
```

Then continue opencode from the main PC and use this file as context.

## Fresh Install Test Command

For the live/test PC, use this after the commit is pushed:

```bash
curl -fsSL https://raw.githubusercontent.com/gldtn/kitana/master/bootstrap.sh | \
  KITANA_UNATTENDED=1 KITANA_BROWSER=brave KITANA_EXTRAS=walls,nvim \
  KITANA_GIT_NAME="gldtn" KITANA_GIT_EMAIL="you@example.com" \
  bash
```

If testing edge packages:

```bash
curl -fsSL https://raw.githubusercontent.com/gldtn/kitana/master/bootstrap.sh | \
  KITANA_UNATTENDED=1 KITANA_EDGE=1 KITANA_BROWSER=brave KITANA_EXTRAS=walls,nvim \
  KITANA_GIT_NAME="gldtn" KITANA_GIT_EMAIL="you@example.com" \
  bash
```

Replace `KITANA_GIT_EMAIL` with the real email before running.

## Failure Logs

If install completes with warnings or fails, check:

```bash
~/.local/state/kitana/install-failures.log
~/.local/state/kitana/install-report.log
```

The failure log includes phase, item, command, exit code, and a manual repair command.

## Known Risks

- AUR packages may still fail due upstream build issues, key imports, package renames, or transient mirror problems.
- `sudo` still requires valid sudo access on the fresh install user.
- `install/preflight/sudoers.sh` can enable `%wheel ALL=(ALL:ALL) ALL`, but it cannot avoid the need for a working initial sudo path.
- `KITANA_GIT_EMAIL` must be set to the real email for unattended Git identity setup.
- `webapp-install` still creates launchers assuming the selected browser supports app-style window flags.
- `ghostty` package availability may vary; edge mode falls back from `ghostty-nightly-bin` to `ghostty`.

## Deferred Items

- opencode desktop theming remains deferred until official documented desktop theme config exists.
- Quickshell native blur remains blocked by current compositor support.
- Fresh install testing still needs to be performed on the live/test PC after pulling this commit.
