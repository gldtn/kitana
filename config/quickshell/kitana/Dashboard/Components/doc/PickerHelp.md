# Picker Help

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable dashboard rows, buttons, fields, and picker helpers area.

PickerHelp is a reusable Dashboard component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `Dashboard/Components/PickerHelp.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`.

Referenced or instantiated by: `Dashboard/Tabs/ThemesTab.qml`, `Dashboard/Tabs/WallpapersTab.qml`.

## Component Hierarchy and Role

The root type is `Item`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `dashboard` | `var` | `null` | No | Provides component state or configuration for `dashboard`. |
| `searchActive` | `readonly bool` | `dashboard && dashboard.pickerSearchActive` | No | Read-only. Enables or disables the `searchActive` state. |
| `helpVisible` | `readonly bool` | `dashboard && dashboard.pickerHelpVisible` | No | Read-only. Enables or disables the `helpVisible` state. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
PickerHelp {
}
```
