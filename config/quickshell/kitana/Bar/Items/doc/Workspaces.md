# Workspaces

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the individual controls embedded in the top bar area.

Workspaces is an interactive control embedded in the top bar.

## Project Structure and Dependencies

Source file: `Bar/Items/Workspaces.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`, `import Quickshell`, `import Quickshell.Hyprland`, `import Quickshell.Io`.

Project imports: `import "../.."`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Bar/Sections/Left.qml`.

## Component Hierarchy and Role

The root type is `Item`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `panelScreen` | `var` | None | Yes | Selects the Quickshell screen or monitor that owns this window or bar instance. |
| `defaultWorkspaceSet` | `readonly var` | `[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]` | No | Read-only. Provides component state or configuration for `defaultWorkspaceSet`. |
| `activeWorkspaceId` | `readonly int` | `{` | No | Read-only. Controls the numeric value for `activeWorkspaceId`. |
| `workspaceStates` | `readonly var` | `{` | No | Read-only. Provides component state or configuration for `workspaceStates`. |
| `workspaceSets` | `var` | `[[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]]` | No | Provides component state or configuration for `workspaceSets`. |
| `embedded` | `bool` | `false` | No | Switches the component into shared-pill mode so its own background is suppressed by a parent container. |

## Methods

#### screenIndex(screen) : void

Performs component-specific behavior used internally or by parent components.

#### screenName(screen) : void

Returns a semantic name used by the icon or display mapping.

#### workspacesFor(screen) : void

Performs component-specific behavior used internally or by parent components.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Uses Quickshell Hyprland state for workspace, monitor, or compositor integration.

Starts external commands through Quickshell process helpers or `Process` objects.

## Usage Example

```qml
Workspaces {
    panelScreen: Quickshell.screens[0]
    embedded: false
}
```
