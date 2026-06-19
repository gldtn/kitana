# Confirm Button

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable control panel controls and rows area.

ConfirmButton is a reusable System component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `System/Components/ConfirmButton.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Session/SessionPanel.qml`, `System/Components/ConfirmOverlay.qml`.

## Component Hierarchy and Role

The root type is `Rectangle`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `label` | `string` | `""` | No | Stores the text label displayed by the control. |
| `danger` | `bool` | `false` | No | Enables or disables the `danger` state. |

## Signals

#### clicked()

Emitted by user interaction or component state changes. Connected handlers should respond by updating parent state or invoking the requested action.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
ConfirmButton {
    label: ""
}
```
