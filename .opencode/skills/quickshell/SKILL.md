---
name: quickshell
description: Work on Quickshell desktop-shell configs for Arch Linux + Hyprland. Use for Quickshell QML panels, widgets, popups, services, IPC, multi-monitor behavior, Hyprland integration, logs, reloads, and debugging.
compatibility: opencode
metadata:
  stack: arch-hyprland-quickshell-qml
---

# Quickshell Skill

Use this skill when working on this repository's Quickshell configuration.

This project is a Quickshell/QML desktop shell for Hyprland on Arch Linux. Treat it as a desktop-shell codebase, not a normal standalone Qt app.

## Source Of Truth

Edit repository source first:

- `config/quickshell/kitana/`
- `config/quickshell/kitana/Services/qmldir`

Do not treat live files under `~/.config/quickshell/kitana/` as the source of truth. Deploy or reload through Kitana commands after repository changes.

## API Rule

Do not guess unfamiliar Quickshell APIs from memory.

Prefer current local definitions and docs:

```bash
find /usr/lib/qt6/qml/Quickshell -name '*.qmltypes' -print
```

Use Quickshell v0.3 docs when local types are not enough:

```text
https://quickshell.org/docs/v0.3.0/
```

Prefer native Quickshell services and types before shell polling, especially for Bluetooth, PipeWire, MPRIS, notifications, networking, tray, and Wayland/Hyprland integration.

## QML Rules

For QML edits, also apply the project `qt-qml` skill.

Keep state declarative where practical:

- Bind view state to root properties instead of assigning child properties directly.
- Avoid assignments that accidentally destroy bindings.
- Use `readonly property` for derived values that should not be assigned.
- Keep delegates explicit with `required property` model roles.
- Prefer `pragma ComponentBehavior: Bound` for delegate-heavy files after verifying required qualifications.

## Services

When adding a Quickshell singleton service:

- Add the service under `config/quickshell/kitana/Services/`.
- Register it in `config/quickshell/kitana/Services/qmldir`.
- Prefer typed properties over `property var` when the shape is stable.
- Keep external commands behind small service functions or Kitana helper scripts.

## Theme Colors

Keep Quickshell color role shape in `Config/Colors.qml` and `themes/*.jsonc`. Static themes and `kitana-matugen` should write the same strict `Theme/current.json` schema instead of generating `Colors.qml`. Reusable QML should use semantic `Colors` roles, not native theme source names.
When adding color transforms, update both `Config/Colors.qml` and the Lua theme resolver so live Quickshell colors and generated app themes resolve the same JSON.

Do not use `validate.sh` as the normal color-role regression check during active UI iteration. Run targeted generation checks for the changed roles.

## Validation

Use the smallest useful checks after changes:

```bash
qmllint --json - -I config/quickshell/kitana -I config/quickshell <files>
git diff --check
```

Use `bash validate.sh` for full install or repair validation, not every small Quickshell edit.

For runtime checks:

```bash
quickshell ipc -c kitana show
quickshell log -c kitana --no-color
kitana-quickshell restart
```

Use targeted reloads where possible. Restart Quickshell when changing service singletons, `qmldir`, IPC surfaces, or module load structure.

## Debugging

When diagnosing behavior:

- Check Quickshell logs before guessing.
- Verify IPC names with `quickshell ipc -c kitana show`.
- Reproduce with the smallest affected panel, popup, service, or component.
- Check Hyprland integration separately from QML rendering when a problem may be compositor state, monitor layout, or layer-shell behavior.
