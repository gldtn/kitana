# Tab Button

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable dashboard rows, buttons, fields, and picker helpers area.

TabButton is a reusable Dashboard component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `Dashboard/Components/TabButton.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Dashboard/DashboardPanel.qml`, `Settings/SettingsPanel.qml`.

## Component Hierarchy and Role

The root type is `Rectangle`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `dashboard` | `var` | `null` | No | Provides component state or configuration for `dashboard`. |
| `iconName` | `string` | `Icons.defaultIcon` | No | Selects a semantic icon token from the Kitana icon registry. |
| `label` | `string` | `""` | No | Stores the text label displayed by the control. |
| `tab` | `string` | `""` | No | Stores the string value for `tab`. |
| `compact` | `bool` | `false` | No | Enables or disables the `compact` state. |
| `selected` | `readonly bool` | `dashboard && dashboard.activeTab === tab` | No | Read-only. Enables or disables the `selected` state. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
TabButton {
    iconName: ""
    label: ""
}
```
