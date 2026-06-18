# Today Fact

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable dashboard rows, buttons, fields, and picker helpers area.

TodayFact is a reusable Dashboard component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `Dashboard/Components/TodayFact.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Dashboard/Tabs/DateTimeTab.qml`.

## Component Hierarchy and Role

The root type is `RowLayout`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `iconName` | `string` | `Icons.defaultIcon` | No | Selects a semantic icon token from the Kitana icon registry. |
| `label` | `string` | `""` | No | Stores the text label displayed by the control. |
| `value` | `string` | `""` | No | Stores the string value for `value`. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
TodayFact {
    iconName: ""
    label: ""
}
```
