# Layout

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the individual controls embedded in the top bar area.

Layout is an interactive control embedded in the top bar.

## Project Structure and Dependencies

Source file: `Bar/Items/Layout.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`, `import Quickshell.Hyprland`, `import Quickshell.Io`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../Services" as Services`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Bar/Sections/Left.qml`, `Bar/StartMenu.qml`, `Components/Controls/KeyHintBar.qml`, `Dashboard/Components/DashboardField.qml`, `Dashboard/Components/MediaButton.qml`, `Dashboard/Components/MediaDeviceRow.qml`, `Dashboard/Components/MiniButton.qml`, `Dashboard/Components/PickerFooter.qml`, `Dashboard/Components/PickerHelp.qml`, `Dashboard/Components/PickerTopInset.qml`, `Dashboard/Components/TabButton.qml`, `Dashboard/Components/TodayFact.qml`.

## Component Hierarchy and Role

The root type is `Item`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `kitanaDir` | `readonly string` | `Quickshell.env("KITANA_DIR") \|\| Quickshell.env("HOME") + "/.local/share/kitana"` | No | Read-only. Stores the Kitana repository path used to call helper commands. |
| `helper` | `readonly string` | `kitanaDir + "/bin/kitana-hyprland-workspace-layout-toggle"` | No | Read-only. Stores the string value for `helper`. |
| `activeWorkspace` | `readonly var` | `Hyprland.focusedWorkspace \|\| Hyprland.workspaces.values.find(workspace => workspace.act...` | No | Read-only. Provides component state or configuration for `activeWorkspace`. |
| `workspaceIpc` | `readonly var` | `activeWorkspace && activeWorkspace.lastIpcObject ? activeWorkspace.lastIpcObject : ({})` | No | Read-only. Provides component state or configuration for `workspaceIpc`. |
| `currentLayout` | `readonly string` | `normalizeLayout(workspaceIpc.tiledLayout \|\| "dwindle")` | No | Read-only. Stores the string value for `currentLayout`. |
| `displayMode` | `readonly string` | `Services.UiPreferences.layoutPillDisplayMode` | No | Read-only. Stores the string value for `displayMode`. |
| `embedded` | `bool` | `false` | No | Switches the component into shared-pill mode so its own background is suppressed by a parent container. |

## Methods

#### normalizeLayout(layout: string) : string

Performs component-specific behavior used internally or by parent components.

#### compactLabel(layout: string) : string

Performs component-specific behavior used internally or by parent components.

#### fullLabel(layout: string) : string

Performs component-specific behavior used internally or by parent components.

#### visibleLabel(layout: string) : string

Performs component-specific behavior used internally or by parent components.

#### refreshWorkspaces() : void

Refreshes data used by the component. Side effects may include starting a process, updating service state, or repopulating a model.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.UiPreferences`.

Uses Quickshell Hyprland state for workspace, monitor, or compositor integration.

Starts external commands through Quickshell process helpers or `Process` objects.

## Usage Example

```qml
Layout {
    embedded: false
}
```
