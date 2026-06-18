# World Clock Row

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable dashboard rows, buttons, fields, and picker helpers area.

WorldClockRow is a reusable Dashboard component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `Dashboard/Components/WorldClockRow.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Dashboard/Tabs/DateTimeTab.qml`.

## Component Hierarchy and Role

The root type is `RowLayout`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `name` | `string` | `""` | No | Stores the string value for `name`. |
| `clockDateText` | `string` | `""` | No | Stores the string value for `clockDateText`. |
| `clockTimeText` | `string` | `"--"` | No | Stores the string value for `clockTimeText`. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
WorldClockRow {
}
```
