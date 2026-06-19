# Dashboard Field

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable dashboard rows, buttons, fields, and picker helpers area.

DashboardField is a reusable Dashboard component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `Dashboard/Components/DashboardField.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Dashboard/Tabs/SettingsTab.qml`.

## Component Hierarchy and Role

The root type is `ColumnLayout`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

The editable value is rendered through `Controls.InputField`.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `label` | `string` | `""` | No | Stores the text label displayed by the control. |
| `value` | `string` | `""` | No | Stores the string value for `value`. |
| `secret` | `bool` | `false` | No | Enables or disables the `secret` state. |

## Signals

#### committed(string value)

Emitted by user interaction or component state changes. Connected handlers should respond by updating parent state or invoking the requested action.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
DashboardField {
    label: ""
}
```
