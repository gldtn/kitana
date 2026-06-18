# System Panel

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the system quick-settings panel shell area.

SystemPanel is a layer-shell panel window in the System module.

## Project Structure and Dependencies

Source file: `System/SystemPanel.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`, `import Quickshell.Io`, `import Quickshell.Wayland`.

Project imports: `import ".."`, `import "../custom" as Custom`, `import "../Services" as Services`, `import "./Components" as System`, `import "./Panes" as Panes`.

Referenced or instantiated by: `Bar/BarWindow.qml`.

## Component Hierarchy and Role

The root type is `PanelWindow`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `panelSelf` | `readonly var` | `root` | No | Read-only. Provides component state or configuration for `panelSelf`. |
| `outerGap` | `readonly int` | `6` | No | Read-only. Controls the numeric value for `outerGap`. |
| `panelVisible` | `bool` | `false` | No | Tracks whether the panel window should be visible. |
| `revealProgress` | `real` | `0` | No | Controls the numeric value for `revealProgress`. |
| `panelScreen` | `var` | `null` | No | Selects the Quickshell screen or monitor that owns this window or bar instance. |
| `section` | `string` | `"notifications"` | No | Tracks which panel section or pane is active. |

## Methods

#### open(targetSection) : void

Opens the component or switches it to the requested section/tab. Side effects usually include focus changes, state reset, or data refresh.

#### close() : void

Closes the component and resets transient state used while visible.

#### toggle(targetSection) : void

Toggles the component between open and closed states, often preserving or selecting a requested section.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.SystemStatus`.
