# Left

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the left, center, and right composition groups for the top bar area.

Left groups related top-bar controls into a section.

## Project Structure and Dependencies

Source file: `Bar/Sections/Left.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../Items" as Items`.

Referenced or instantiated by: `Bar/BarWindow.qml`.

## Component Hierarchy and Role

The root type is `Item`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `panelScreen` | `var` | `null` | No | Selects the Quickshell screen or monitor that owns this window or bar instance. |
| `startMenu` | `var` | `null` | No | Receives the start menu instance that this control opens or toggles. |
| `embedded` | `bool` | `false` | No | Switches the component into shared-pill mode so its own background is suppressed by a parent container. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
Left {
    embedded: false
}
```
