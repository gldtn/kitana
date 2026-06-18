# Start Menu

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the per-monitor top bar windows and start menu overlays area.

StartMenu is a layer-shell panel window in the Bar module.

## Project Structure and Dependencies

Source file: `Bar/StartMenu.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`, `import Quickshell`, `import Quickshell.Wayland`.

Project imports: `import ".."`, `import "../Components/Controls" as Controls`, `import "../custom" as Custom`.

Referenced or instantiated by: `Bar/BarWindow.qml`.

## Component Hierarchy and Role

The root type is `PanelWindow`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `panelScreen` | `var` | `null` | No | Selects the Quickshell screen or monitor that owns this window or bar instance. |
| `systemPanel` | `var` | `null` | No | Receives the system panel instance used to open quick-settings detail sections. |
| `settingsPanel` | `var` | `null` | No | Receives the shared settings panel instance used by menu actions. |
| `shortcutsPanel` | `var` | `null` | No | Receives the shared shortcuts panel instance used by menu actions. |
| `panelVisible` | `bool` | `false` | No | Tracks whether the panel window should be visible. |
| `revealProgress` | `real` | `0` | No | Controls the numeric value for `revealProgress`. |

## Signals

#### clicked()

Emitted by user interaction or component state changes. Connected handlers should respond by updating parent state or invoking the requested action.


## Methods

#### open() : void

Opens the component or switches it to the requested section/tab. Side effects usually include focus changes, state reset, or data refresh.

#### close() : void

Closes the component and resets transient state used while visible.

#### toggle() : void

Toggles the component between open and closed states, often preserving or selecting a requested section.

#### openLauncher() : void

Performs component-specific behavior used internally or by parent components.

#### openSettings() : void

Performs component-specific behavior used internally or by parent components.

#### openShortcuts() : void

Performs component-specific behavior used internally or by parent components.


## Inline Components

| Component | Base Type | Description |
|-----------|-----------|-------------|
| `MenuAction` | `Rectangle` | Inline helper component local to this file. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Starts external commands through Quickshell process helpers or `Process` objects.
