# Style

- Use two spaces for shell indentation where practical; keep existing file style when editing established scripts.
- Use `#!/bin/bash` for executable shell scripts.
- Scripts under `install/` may be sourced by other scripts; avoid adding shebangs there unless the script is intended to run directly.
- Prefer arrays for package lists and command arguments.
- Quote paths and values that may contain spaces, especially file paths and command arguments.
- Keep shell helpers small and direct; avoid adding abstractions unless they remove real duplication.
- Use ASCII by default.
- Do not add compatibility wrappers for renamed commands unless there is a concrete persisted or external compatibility need.

# Command Naming

All user-facing helper commands live in `bin/` and start with `kitana-`.

Common prefixes:

- `kitana-install-*` - install optional or personal software.
- `kitana-refresh` - refresh generated or deployed files without reinstalling packages.
- `kitana-reinstall` - rerun broader install or repair flows.
- `kitana-theme*` - theme generation and theme application.
- `kitana-webapp-*` - web app desktop entry management and launching.

Keep commands flat in `bin/`; do not create nested command directories because `$PATH` only searches direct directories.

# Install Scripts

Install entry points use `#!/bin/bash` and initialize shared paths through `install/lib/install.sh`.

Shared install variables:

- `KITANA_DIR` - Kitana repository path, usually `~/.local/share/kitana`.
- `KITANA_INSTALL` - install script directory, usually `$KITANA_DIR/install`.
- `PATH` - should include `$KITANA_DIR/bin` during install and repair flows.

Install guidance:

- Source `install/lib/install.sh` before using shared install helpers.
- Use `kitana_init_paths` for path setup instead of hard-coded repository paths.
- Use `source_script` for ordered sourced install stages when applicable.
- Avoid `exit` inside sourced install leaf scripts unless the whole install must abort.
- Use `kitana_install_required` and `kitana_install_optional` for package installs so failures are logged consistently.
- Use `kitana-pkg-add` from standalone commands when installing packages outside the sourced install flow.
- Keep optional/personal software in explicit `kitana-install-*` commands, not installer flags.

# Config Structure

- `applications/` - Kitana-managed desktop entries and hidden application overrides.
- `bin/` - executable `kitana-*` helper commands.
- `config/` - user-facing configs copied into `~/.config` or `$HOME`.
- `default/` - Kitana defaults, assets, Hyprland Lua modules, wallpapers, SDDM theme source, and other deployed defaults.
- `default/xcompose` - base XCompose shortcuts deployed to `~/.XCompose`; keyboard presets are managed by `kitana-keyboard`.
- `install/` - install stages and shared install libraries.
- `lib/` - shared non-install libraries.
- `NOTES.md` - temporary clean-install testing notes and session handoff context.
- `themes/` - Kitana theme palettes and theme helpers.
- `TODO.md` - tracked follow-up work and deferred improvements.
- `vendor/` - bundled upstream data used by generators.

Do not edit live user config as the source of truth. Update repository files first, then use the relevant refresh command or install script to deploy.

Many deployed configs are intentionally preserved once the user has edited them. Before changing refresh/install behavior, check the marker strings in `install/desktop/configs.sh` so user-owned files are not overwritten accidentally.

# Fresh Install Diagnostics

Fresh installs start from `bootstrap.sh`, then `install.sh`, then `install-desktop.sh` and `install-apps.sh`.

Install logs:

- `~/.local/state/kitana/install-report.log` - full install report.
- `~/.local/state/kitana/install-failures.log` - tracked failures needing review.
- `~/.local/state/kitana/package-logs/` - per-package command output logs.

When diagnosing a fresh install, inspect these logs before changing installer code. Optional package failures may be logged and intentionally non-fatal.

# Refresh And Repair

Preferred repair commands:

- `kitana-reinstall`
- `kitana-reinstall --system`
- `kitana-reinstall --desktop`
- `kitana-reinstall --apps`
- `kitana-reinstall --configs`
- `kitana-refresh --applications`
- `kitana-refresh --configs`
- `kitana-refresh --sddm`
- `kitana-refresh --wallpapers`

Use targeted refresh commands when possible instead of rerunning the full installer.

# Themes

Theme definitions live in `themes/*.lua`; shared theme loading and color resolution lives in `lib/kitana-theme.lua`.

Theme application flow:

- `kitana-theme THEME` applies the selected theme and writes `~/.config/kitana/theme`.
- `kitana-theme-quickshell` generates Quickshell colors.
- `kitana-theme-ghostty` updates Ghostty theme state.
- `kitana-theme-zed` writes `~/.config/zed/themes/kitana-dynamic.json`, often from `vendor/zed/*.json`.
- `kitana-theme-hypr` writes `~/.config/hypr/kitana-theme.lua` and reloads Hyprland when available.

When adding or editing themes, update `lib/kitana-theme.lua` ordering/mappings as needed and validate generated consumers with the smallest relevant command.

# Quickshell

Kitana Quickshell config lives in `config/quickshell/kitana/` and deploys to `~/.config/quickshell/kitana/`.

Before adding Quickshell functionality, consult the v0.3 docs at `https://quickshell.org/docs/v0.3.0/`. Prefer native Quickshell services and types, such as Bluetooth, PipeWire, MPRIS, notifications, networking, and tray APIs, before adding shell polling or helper commands. Use external commands only when Quickshell lacks the required behavior or a helper is clearly simpler and more reliable.

Useful lifecycle commands:

- `kitana-quickshell` - reload if running, otherwise start.
- `kitana-quickshell start`
- `kitana-quickshell stop`
- `kitana-quickshell restart`
- `kitana-quickshell reload`

When adding a new Quickshell service singleton, register it in `config/quickshell/kitana/Services/qmldir` and update validation if it is required.

For launcher or modal changes:

- Keep first-run behavior populated and keyboard-safe.
- Avoid search keybindings that conflict with normal text input.
- Resolve application icons through Quickshell icon helpers or existing Kitana renderer patterns.
- Restart Quickshell when testing service singleton or desktop entry cache changes.

# Hyprland

Kitana uses Hyprland Lua defaults from `default/hypr/`.

- The live entrypoint is `~/.config/hypr/hyprland.lua`.
- The entrypoint loads Kitana defaults first, then local custom modules.
- Keep user customization in `~/.config/hypr/custom/*.lua`.
- Do not edit generated live configs as the only change; update repository defaults when behavior should be tracked.
- Validate Lua edits with `luac -p` where available.

# SDDM

Kitana owns its SDDM theme and greeter compositor config.

- Source theme: `default/sddm/theme/`.
- Source greeter compositor config: `default/sddm/hyprland.lua`.
- Refresh command: `kitana-refresh --sddm`.
- Test mode: `kitana-refresh --sddm --test-mode` or `sddm-greeter --test-mode --theme /usr/share/sddm/themes/kitana`.

Do not enable SDDM autologin unless explicitly requested.

# Applications

Application desktop entries and hidden overrides live in `applications/`.

- Use `applications/hidden/*.desktop` for desktop entries that should be hidden from app launchers.
- Hidden overrides should use the same basename as the system desktop entry and contain `NoDisplay=true`.
- User-specific hidden entry overrides live in `~/.config/kitana/applications/hidden/*.desktop` and take precedence over Kitana defaults.
- Set `NoDisplay=false` in a user override to unhide a Kitana default-hidden app without changing the repo.
- Run `kitana-refresh --applications` after changing application entries or hidden overrides.
- Kitana's Quickshell app search may also filter launcher noise directly when desktop entry overrides are not enough.

# Validation

Before committing substantial changes, run the smallest useful checks for the files changed.

Common checks:

- `bash -n <script>` for shell scripts.
- `luac -p <file>` for Lua files.
- `git diff --check` for whitespace issues.
- `bash validate.sh` for full install validation when feasible.

For Quickshell work, also check:

- `quickshell ipc -c kitana show`
- `quickshell log -c kitana --no-color`
- `kitana-quickshell restart`

# Git

- Check `git status --short`, `git diff`, and recent commits before committing.
- Stage only intended files.
- Do not amend commits unless explicitly requested.
- Do not revert unrelated user changes.
- Keep commit messages short and imperative.
