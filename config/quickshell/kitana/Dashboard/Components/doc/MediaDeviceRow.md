# Media Device Row

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable dashboard rows, buttons, fields, and picker helpers area.

MediaDeviceRow is a reusable Dashboard component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `Dashboard/Components/MediaDeviceRow.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Dashboard/Tabs/MediaTab.qml`.

## Component Hierarchy and Role

The root type is `Rectangle`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `name` | `string` | `""` | No | Stores the string value for `name`. |
| `iconName` | `string` | `"audio.output"` | No | Selects a semantic icon token from the Kitana icon registry. |
| `subtitle` | `string` | `"Output device"` | No | Stores secondary explanatory text shown by the component. |
| `active` | `bool` | `false` | No | Enables or disables the `active` state. |

## Signals

#### clicked()

Emitted by user interaction or component state changes. Connected handlers should respond by updating parent state or invoking the requested action.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
MediaDeviceRow {
    iconName: ""
    active: false
}
```
