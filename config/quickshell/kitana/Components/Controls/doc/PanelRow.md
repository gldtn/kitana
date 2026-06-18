# Panel Row

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the shared reusable controls used across panels and popups area.

PanelRow is a reusable Components component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `Components/Controls/PanelRow.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`, `import "../../custom" as Custom`.

No direct QML instantiations were found; the component is an entrypoint, singleton, or loaded indirectly.

## Component Hierarchy and Role

The root type is `Rectangle`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `iconName` | `string` | `Icons.defaultIcon` | No | Selects a semantic icon token from the Kitana icon registry. |
| `title` | `string` | `""` | No | Stores the primary label shown by the component. |
| `subtitle` | `string` | `""` | No | Stores secondary explanatory text shown by the component. |
| `highlighted` | `bool` | `false` | No | Enables or disables the `highlighted` state. |
| `clickable` | `bool` | `true` | No | Enables or disables the `clickable` state. |

## Signals

#### clicked()

Emitted by user interaction or component state changes. Connected handlers should respond by updating parent state or invoking the requested action.

## Inter-Component Interactions

Interactions are limited to parent bindings, local child composition, and shared design token imports.

## Usage Example

```qml
PanelRow {
    iconName: ""
    title: ""
}
```
