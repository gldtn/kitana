# Right

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the left, center, and right composition groups for the top bar area.

Right groups related top-bar controls into a section.

## Project Structure and Dependencies

Source file: `Bar/Sections/Right.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../Items" as Items`.

Referenced or instantiated by: `Bar/BarWindow.qml`.

## Component Hierarchy and Role

The root type is `Item`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `panelWindow` | `var` | `null` | No | Provides component state or configuration for `panelWindow`. |
| `screenshotPanel` | `var` | `null` | No | Receives the shared screenshot panel instance used to open or toggle capture controls. |
| `systemPanel` | `var` | `null` | No | Receives the system panel instance used to open quick-settings detail sections. |
| `embedded` | `bool` | `false` | No | Switches the component into shared-pill mode so its own background is suppressed by a parent container. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
Right {
    embedded: false
}
```
