# App Launcher

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the application launcher and search UI area.

AppLauncher is a layer-shell panel window in the Launcher module.

## Project Structure and Dependencies

Source file: `Launcher/AppLauncher.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Controls`, `import QtQuick.Layouts`, `import Quickshell`, `import Quickshell.Hyprland`, `import Quickshell.Io`, `import Quickshell.Wayland`, `import Quickshell.Widgets as QW`.

Project imports: `import ".."`, `import "../Components/Controls" as Controls`, `import "../custom" as Custom`, `import "../Services" as Services`.

Referenced or instantiated by: `shell.qml`.

## Component Hierarchy and Role

The root type is `PanelWindow`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

The launcher header uses `Controls.CloseButton` for explicit dismissal.

Launcher results use borderless zebra rows with subtle hover and keyboard-selection tinting.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `query` | `string` | `""` | No | Stores the current search/filter text. |
| `results` | `var` | `[]` | No | Provides component state or configuration for `results`. |
| `panelVisible` | `bool` | `false` | No | Tracks whether the panel window should be visible. |
| `selectedIndex` | `int` | `0` | No | Tracks the currently selected item for keyboard navigation. |
| `statusText` | `string` | `""` | No | Stores user-facing status text for loading, empty, or error states. |
| `cardWidth` | `readonly int` | `Math.min(720, width - 96)` | No | Read-only. Controls the numeric value for `cardWidth`. |
| `cardHeight` | `readonly int` | `Math.min(620, height - 120)` | No | Read-only. Controls the numeric value for `cardHeight`. |

## Methods

#### refreshResults() : void

Refreshes data used by the component. Side effects may include starting a process, updating service state, or repopulating a model.

#### moveSelection(delta: int) : void

Updates keyboard selection or page state used by navigation.

#### shellQuote(value) : string

Performs component-specific behavior used internally or by parent components.

#### luaQuote(value) : string

Performs component-specific behavior used internally or by parent components.

#### currentWorkspaceId() : int

Performs component-specific behavior used internally or by parent components.

#### commandString(command, workingDirectory) : string

Performs component-specific behavior used internally or by parent components.

#### launchCommandOnWorkspace(command, workingDirectory, workspaceId: int) : bool

Performs component-specific behavior used internally or by parent components.

#### launchItem(item) : void

Performs component-specific behavior used internally or by parent components.

#### launchCurrent() : void

Performs component-specific behavior used internally or by parent components.

#### iconSource(item) : string

Returns a semantic name used by the icon or display mapping.

#### open() : void

Opens the component or switches it to the requested section/tab. Side effects usually include focus changes, state reset, or data refresh.

#### close() : void

Closes the component and resets transient state used while visible.

#### toggle() : void

Toggles the component between open and closed states, often preserving or selecting a requested section.

#### onApplicationsChanged() : void

Performs component-specific behavior used internally or by parent components.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.AppSearchService`.

Uses Quickshell Hyprland state for workspace, monitor, or compositor integration.

Starts external commands through Quickshell process helpers or `Process` objects.

Exposes IPC targets: `kitana-launcher`.
