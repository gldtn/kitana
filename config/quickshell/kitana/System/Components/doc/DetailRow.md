# Detail Row

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable system panel controls and rows area.

DetailRow is a reusable System component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `System/Components/DetailRow.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`.

Referenced or instantiated by: `System/Panes/AudioPane.qml`, `System/Panes/BluetoothPane.qml`, `System/Panes/NetworkPane.qml`, `System/Panes/SessionPane.qml`, `System/Panes/SettingsPane.qml`.

## Component Hierarchy and Role

The root type is `Rectangle`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `iconName` | `string` | `Icons.defaultIcon` | No | Selects a semantic icon token from the Kitana icon registry. |
| `title` | `string` | `""` | No | Stores the primary label shown by the component. |
| `subtitle` | `string` | `""` | No | Stores secondary explanatory text shown by the component. |
| `active` | `bool` | `false` | No | Enables or disables the `active` state. |
| `clickable` | `bool` | `true` | No | Enables or disables the `clickable` state. |

## Signals

#### clicked()

Emitted by user interaction or component state changes. Connected handlers should respond by updating parent state or invoking the requested action.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
DetailRow {
    iconName: ""
    title: ""
    active: false
}
```
