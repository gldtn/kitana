# Session Pane

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the control panel detail panes for audio, Bluetooth, network, notifications, settings, and session actions area.

SessionPane is a detail pane in the control panel.

## Project Structure and Dependencies

Source file: `System/Panes/SessionPane.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`, `import "../Components"`, `import "../../custom" as Custom`.

No direct QML instantiations were found; the component is an entrypoint, singleton, or loaded indirectly.

## Component Hierarchy and Role

The root type is `Column`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `panel` | `var` | `null` | No | Provides component state or configuration for `panel`. |

## Inter-Component Interactions

Interactions are limited to parent bindings, local child composition, and shared design token imports.

## Usage Example

```qml
SessionPane {
}
```
