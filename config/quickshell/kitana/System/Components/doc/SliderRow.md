# Slider Row

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable system panel controls and rows area.

SliderRow is a reusable System component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `System/Components/SliderRow.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Controls`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`.

Referenced or instantiated by: `System/Components/ControlSliders.qml`.

## Component Hierarchy and Role

The root type is `Row`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `iconName` | `string` | `Icons.defaultIcon` | No | Selects a semantic icon token from the Kitana icon registry. |
| `value` | `int` | `0` | No | Controls the numeric value for `value`. |
| `label` | `string` | `""` | No | Stores the text label displayed by the control. |
| `iconClickable` | `bool` | `false` | No | Enables or disables the `iconClickable` state. |

## Signals

#### moved(real value)

Emitted by user interaction or component state changes. Connected handlers should respond by updating parent state or invoking the requested action.

#### iconClicked()

Emitted by user interaction or component state changes. Connected handlers should respond by updating parent state or invoking the requested action.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
SliderRow {
    iconName: ""
    label: ""
}
```
