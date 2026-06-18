# Mini Button

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable dashboard rows, buttons, fields, and picker helpers area.

MiniButton is a reusable Dashboard component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `Dashboard/Components/MiniButton.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Dashboard/Tabs/DateTimeTab.qml`, `Dashboard/Tabs/MediaTab.qml`, `Dashboard/Tabs/SettingsTab.qml`, `Dashboard/Tabs/ThemesTab.qml`, `Dashboard/Tabs/WallpapersTab.qml`, `Dashboard/Tabs/WeatherTab.qml`.

## Component Hierarchy and Role

The root type is `Rectangle`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `text` | `string` | `""` | No | Stores the string value for `text`. |
| `iconName` | `string` | `""` | No | Selects a semantic icon token from the Kitana icon registry. |
| `widthOverride` | `int` | `32` | No | Controls the numeric value for `widthOverride`. |
| `heightOverride` | `int` | `28` | No | Controls the numeric value for `heightOverride`. |

## Signals

#### clicked()

Emitted by user interaction or component state changes. Connected handlers should respond by updating parent state or invoking the requested action.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
MiniButton {
    iconName: ""
}
```
