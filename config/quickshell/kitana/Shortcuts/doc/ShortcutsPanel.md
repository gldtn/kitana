# Shortcuts Panel

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the keyboard shortcut reference panel area.

ShortcutsPanel is a layer-shell panel window in the Shortcuts module.

## Project Structure and Dependencies

Source file: `Shortcuts/ShortcutsPanel.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`, `import Quickshell`, `import Quickshell.Io`, `import Quickshell.Wayland`.

Project imports: `import ".."`, `import "../Components/Controls" as Controls`, `import "../custom" as Custom`.

Referenced or instantiated by: `shell.qml`.

## Component Hierarchy and Role

The root type is `PanelWindow`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

The shortcuts header uses `Controls.CloseButton` for explicit dismissal.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `panelScreen` | `var` | `null` | No | Selects the Quickshell screen or monitor that owns this window or bar instance. |
| `panelVisible` | `bool` | `false` | No | Tracks whether the panel window should be visible. |
| `query` | `string` | `""` | No | Stores the current search/filter text. |
| `shortcuts` | `var` | `[]` | No | Provides component state or configuration for `shortcuts`. |
| `filteredShortcuts` | `var` | `[]` | No | Provides component state or configuration for `filteredShortcuts`. |
| `statusText` | `string` | `"Loading shortcuts..."` | No | Stores user-facing status text for loading, empty, or error states. |
| `selectedIndex` | `int` | `0` | No | Tracks the currently selected item for keyboard navigation. |

## Methods

#### open() : void

Opens the component or switches it to the requested section/tab. Side effects usually include focus changes, state reset, or data refresh.

#### close() : void

Closes the component and resets transient state used while visible.

#### toggle() : void

Toggles the component between open and closed states, often preserving or selecting a requested section.

#### refreshShortcuts() : void

Refreshes data used by the component. Side effects may include starting a process, updating service state, or repopulating a model.

#### moveSelection(delta: int) : void

Updates keyboard selection or page state used by navigation.

#### handleKey(event: var) : void

Performs component-specific behavior used internally or by parent components.

#### modifiers(mask: int) : string

Performs component-specific behavior used internally or by parent components.

#### displayKey(key: string) : string

Performs component-specific behavior used internally or by parent components.

#### shortcutLabel(item: var) : string

Performs component-specific behavior used internally or by parent components.

#### fallbackDescription(item: var) : string

Performs component-specific behavior used internally or by parent components.

#### categoryFor(item: var) : string

Performs component-specific behavior used internally or by parent components.

#### loadShortcuts(text: string) : void

Performs component-specific behavior used internally or by parent components.

#### filterShortcuts() : void

Performs component-specific behavior used internally or by parent components.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Starts external commands through Quickshell process helpers or `Process` objects.

Exposes IPC targets: `kitana-shortcuts`.
