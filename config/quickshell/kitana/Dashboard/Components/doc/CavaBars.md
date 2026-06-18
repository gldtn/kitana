# Cava Bars

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable dashboard rows, buttons, fields, and picker helpers area.

CavaBars is a reusable Dashboard component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `Dashboard/Components/CavaBars.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`.

Referenced or instantiated by: `Dashboard/Tabs/MediaTab.qml`.

## Component Hierarchy and Role

The root type is `Item`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `dashboard` | `var` | `null` | No | Provides component state or configuration for `dashboard`. |
| `levels` | `readonly var` | `dashboard ? dashboard.cavaLevels : []` | No | Read-only. Provides component state or configuration for `levels`. |
| `playing` | `readonly bool` | `dashboard ? dashboard.mediaPlaying : false` | No | Read-only. Enables or disables the `playing` state. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
CavaBars {
}
```
