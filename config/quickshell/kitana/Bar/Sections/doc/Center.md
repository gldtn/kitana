# Center

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the left, center, and right composition groups for the top bar area.

Center groups related top-bar controls into a section.

## Project Structure and Dependencies

Source file: `Bar/Sections/Center.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../Items" as Items`.

Referenced or instantiated by: `Bar/BarWindow.qml`.

## Component Hierarchy and Role

The root type is `Item`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `dashboardPanel` | `var` | `null` | No | Receives the shared dashboard panel instance used by bar controls to open dashboard tabs. |
| `embedded` | `bool` | `false` | No | Switches the component into shared-pill mode so its own background is suppressed by a parent container. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
Center {
    embedded: false
}
```
