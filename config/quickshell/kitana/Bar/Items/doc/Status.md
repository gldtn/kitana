# Status

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the individual controls embedded in the top bar area.

Status is an interactive control embedded in the top bar.

## Project Structure and Dependencies

Source file: `Bar/Items/Status.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`, `import Quickshell`, `import Quickshell.Services.SystemTray`, `import Quickshell.Widgets as QW`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`, `import "../../Services" as Services`.

Referenced or instantiated by: `Bar/Sections/Right.qml`.

## Component Hierarchy and Role

The root type is `Item`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `systemPanel` | `var` | `null` | No | Receives the system panel instance used to open quick-settings detail sections. |
| `panelWindow` | `var` | `null` | No | Provides component state or configuration for `panelWindow`. |
| `trayExpanded` | `bool` | `false` | No | Enables or disables the `trayExpanded` state. |
| `embedded` | `bool` | `false` | No | Switches the component into shared-pill mode so its own background is suppressed by a parent container. |

## Signals

#### clicked()

Emitted by user interaction or component state changes. Connected handlers should respond by updating parent state or invoking the requested action.


## Methods

#### traySource(item: var) : string

Performs component-specific behavior used internally or by parent components.

#### trayFallbackIconSourceFor(item: var) : string

Performs component-specific behavior used internally or by parent components.

#### callContextMenuFallback(item: var, globalX: int, globalY: int) : void

Performs component-specific behavior used internally or by parent components.

#### displayMenu(mouse: var) : void

Performs component-specific behavior used internally or by parent components.


## Inline Components

| Component | Base Type | Description |
|-----------|-----------|-------------|
| `StatusButton` | `Item` | Inline helper component local to this file. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.NotificationService`, `Services.SystemStatus`, `Services.SystemTray`.

Uses Quickshell SystemTray data for tray item presentation and actions.

Starts external commands through Quickshell process helpers or `Process` objects.

## Usage Example

```qml
Status {
    embedded: false
}
```
