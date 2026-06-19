# Notification Row

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable control panel controls and rows area.

NotificationRow is a reusable System component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `System/Components/NotificationRow.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`, `import Quickshell`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`, `import "../../Services" as Services`.

Referenced or instantiated by: `System/Panes/NotificationsPane.qml`.

## Component Hierarchy and Role

The root type is `Rectangle`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `item` | `var` | `null` | No | Provides component state or configuration for `item`. |
| `groupCount` | `int` | `1` | No | Controls the numeric value for `groupCount`. |
| `groupExpandable` | `bool` | `false` | No | Enables or disables the `groupExpandable` state. |
| `groupCollapsed` | `bool` | `false` | No | Enables or disables the `groupCollapsed` state. |
| `groupHeader` | `bool` | `false` | No | Enables or disables the `groupHeader` state. |
| `verticalPadding` | `readonly int` | `16` | No | Read-only. Controls the numeric value for `verticalPadding`. |

## Signals

#### toggleGroup()

Emitted by user interaction or component state changes. Connected handlers should respond by updating parent state or invoking the requested action.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.NotificationService`.

Starts external commands through Quickshell process helpers or `Process` objects.

## Usage Example

```qml
NotificationRow {
}
```
