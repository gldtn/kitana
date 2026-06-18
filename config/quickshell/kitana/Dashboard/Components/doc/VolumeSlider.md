# Volume Slider

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable dashboard rows, buttons, fields, and picker helpers area.

VolumeSlider is a reusable Dashboard component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `Dashboard/Components/VolumeSlider.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../custom" as Custom`, `import "../../Services" as Services`.

Referenced or instantiated by: `Dashboard/Tabs/MediaTab.qml`.

## Component Hierarchy and Role

The root type is `Rectangle`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `value` | `int` | `0` | No | Controls the numeric value for `value`. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.SystemStatus`.

## Usage Example

```qml
VolumeSlider {
}
```
