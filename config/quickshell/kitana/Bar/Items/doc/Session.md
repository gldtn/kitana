# Session

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the individual controls embedded in the top bar area.

Session is an interactive control embedded in the top bar.

## Project Structure and Dependencies

Source file: `Bar/Items/Session.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell.Io`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Bar/Sections/Right.qml`, `shell.qml`.

## Component Hierarchy and Role

The root type is `Item`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `embedded` | `bool` | `false` | No | Switches the component into shared-pill mode so its own background is suppressed by a parent container. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Starts external commands through Quickshell process helpers or `Process` objects.

## Usage Example

```qml
Session {
    embedded: false
}
```
