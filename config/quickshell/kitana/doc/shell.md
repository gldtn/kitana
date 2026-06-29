# Shell

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the shell entrypoint and top-level application wiring area.

Shell is the root Quickshell entrypoint that creates shared panels, exposes IPC handlers, and instantiates one bar window plus one collapsed dashboard island per screen.

## Project Structure and Dependencies

Source file: `shell.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`, `import Quickshell.Hyprland`, `import Quickshell.Io`.

Project imports: `import "./Bar" as Bar`, `import "./Dashboard" as Dashboard`, `import "./Launcher" as Launcher`, `import "./Screenshot" as Screenshot`, `import "./Session" as Session`, `import "./Settings" as Settings`, `import "./Shortcuts" as Shortcuts`, `import "./System" as System`, `import "./Theme" as Theme`, `import "./Wallpaper" as Wallpaper`, `import "./Services" as Services`.

No direct QML instantiations were found; the component is an entrypoint, singleton, or loaded indirectly.

## Component Hierarchy and Role

The root type is `ShellRoot`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `barVisible` | `bool` | `true` | No | Controls whether the top bar is shown and reserves exclusive screen space. |
| `sharedScreenshotPanel` | `readonly var` | `screenshotPanel` | No | Read-only. Receives a panel instance used for cross-panel coordination. |
| `sharedSettingsPanel` | `readonly var` | `settingsPanel` | No | Read-only. Receives a panel instance used for cross-panel coordination. |
| `sharedShortcutsPanel` | `readonly var` | `shortcutsPanel` | No | Read-only. Receives a panel instance used for cross-panel coordination. |
| `focusedScreen` | `readonly var` | `screenForMonitor(Hyprland.focusedMonitor)` | No | Tracks the Quickshell screen for the focused Hyprland monitor. |

## Methods

#### display(payload: string) : void

Performs component-specific behavior used internally or by parent components.

#### dismissLast() : void

Performs component-specific behavior used internally or by parent components.

#### clear() : void

Performs component-specific behavior used internally or by parent components.

#### show() : void

Performs component-specific behavior used internally or by parent components.

#### hide() : void

Performs component-specific behavior used internally or by parent components.

#### toggle() : void

Toggles the component between open and closed states, often preserving or selecting a requested section.

#### refreshWorkspaces() : void

Refreshes data used by the component. Side effects may include starting a process, updating service state, or repopulating a model.

#### reload() : void

Performs component-specific behavior used internally or by parent components.

#### hardReload() : void

Performs component-specific behavior used internally or by parent components.

#### screenForMonitor(monitor: var) : var

Returns the Quickshell screen matching a Hyprland monitor.

#### open() : void

Opens the component or switches it to the requested section/tab. Side effects usually include focus changes, state reset, or data refresh.

#### close() : void

Closes the component and resets transient state used while visible.

## Inter-Component Interactions

Reads from or calls service singletons: `Services.NotificationService`, `Services.OsdService`.

Uses Quickshell Hyprland state for workspace, monitor, or compositor integration.

Exposes IPC targets: `kitana-osd`, `kitana-notifications`, `kitana-bar`, `kitana-shell`, `kitana-screenshot`, `kitana-control-panel`.
