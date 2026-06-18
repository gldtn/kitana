# Icon

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the shared reusable controls used across panels and popups area.

Icon is a reusable Components component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `Components/Controls/Icon.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Bar/Items/DateTime.qml`, `Bar/Items/Layout.qml`, `Bar/Items/Screenshot.qml`, `Bar/Items/Session.qml`, `Bar/Items/Start.qml`, `Bar/Items/Status.qml`, `Bar/StartMenu.qml`, `Components/Controls/PanelRow.qml`, `Dashboard/Components/MediaButton.qml`, `Dashboard/Components/MediaDeviceRow.qml`, `Dashboard/Components/MiniButton.qml`, `Dashboard/Components/TabButton.qml`.

## Component Hierarchy and Role

The root type is `Text`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `name` | `string` | `Icons.defaultIcon` | No | Stores the string value for `name`. |
| `tone` | `string` | `"primary"` | No | Stores the string value for `tone`. |
| `sizeRole` | `string` | `"button"` | No | Stores the string value for `sizeRole`. |
| `size` | `int` | `0` | No | Controls the numeric value for `size`. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
Icon {
}
```
