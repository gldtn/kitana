# Weather Metric

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable dashboard rows, buttons, fields, and picker helpers area.

WeatherMetric is a reusable Dashboard component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `Dashboard/Components/WeatherMetric.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Dashboard/Tabs/WeatherTab.qml`.

## Component Hierarchy and Role

The root type is `Item`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `iconName` | `string` | `Icons.defaultIcon` | No | Selects a semantic icon token from the Kitana icon registry. |
| `label` | `string` | `""` | No | Stores the text label displayed by the control. |
| `value` | `string` | `""` | No | Stores the string value for `value`. |
| `labelPixelSize` | `int` | `settings.textPixelSize - 1` | No | Controls the numeric value for `labelPixelSize`. |
| `valuePixelSize` | `int` | `settings.textPixelSize` | No | Controls the numeric value for `valuePixelSize`. |
| `valueWeight` | `int` | `Font.DemiBold` | No | Controls the numeric value for `valueWeight`. |
| `contentWidth` | `int` | `108` | No | Controls the numeric value for `contentWidth`. |
| `iconWidth` | `int` | `18` | No | Controls the numeric value for `iconWidth`. |
| `centerContent` | `bool` | `false` | No | Enables or disables the `centerContent` state. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
WeatherMetric {
    iconName: ""
    label: ""
}
```
