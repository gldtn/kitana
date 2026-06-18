# Wallpaper Grid

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the wallpaper picker grid and wallpaper application flow area.

WallpaperGrid is a layer-shell panel window in the Wallpaper module.

## Project Structure and Dependencies

Source file: `Wallpaper/WallpaperGrid.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Controls`, `import QtQuick.Effects`, `import QtQuick.Layouts`, `import Quickshell`, `import Quickshell.Io`, `import Quickshell.Wayland`.

Project imports: `import ".."`, `import "../Components/Controls" as Controls`, `import "../custom" as Custom`.

Referenced or instantiated by: `shell.qml`.

## Component Hierarchy and Role

The root type is `PanelWindow`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `wallpapers` | `var` | `[]` | No | Provides component state or configuration for `wallpapers`. |
| `filteredWallpapers` | `var` | `[]` | No | Provides component state or configuration for `filteredWallpapers`. |
| `query` | `string` | `""` | No | Stores the current search/filter text. |
| `statusText` | `string` | `""` | No | Stores user-facing status text for loading, empty, or error states. |
| `panelVisible` | `bool` | `false` | No | Tracks whether the panel window should be visible. |
| `helpVisible` | `bool` | `false` | No | Enables or disables the `helpVisible` state. |
| `searchActive` | `bool` | `false` | No | Enables or disables the `searchActive` state. |
| `kitanaDir` | `string` | `Quickshell.env("KITANA_DIR") \|\| Quickshell.env("HOME") + "/.local/share/kitana"` | No | Stores the Kitana repository path used to call helper commands. |
| `selectedIndex` | `int` | `-1` | No | Tracks the currently selected item for keyboard navigation. |
| `cardWidth` | `readonly int` | `Math.min(900, width - 160)` | No | Read-only. Controls the numeric value for `cardWidth`. |
| `cardHeight` | `readonly int` | `Math.min(560, height - 160)` | No | Read-only. Controls the numeric value for `cardHeight`. |

## Methods

#### basename(path) : void

Performs component-specific behavior used internally or by parent components.

#### fileUrl(path) : void

Performs component-specific behavior used internally or by parent components.

#### refreshFilter() : void

Refreshes data used by the component. Side effects may include starting a process, updating service state, or repopulating a model.

#### applyWallpaper(path) : void

Applies the requested user selection by invoking the associated service or Kitana helper command.

#### applyCurrent() : void

Applies the requested user selection by invoking the associated service or Kitana helper command.

#### gridColumns() : void

Performs component-specific behavior used internally or by parent components.

#### moveSelection(delta) : void

Updates keyboard selection or page state used by navigation.

#### handleKey(event) : void

Performs component-specific behavior used internally or by parent components.

#### open() : void

Opens the component or switches it to the requested section/tab. Side effects usually include focus changes, state reset, or data refresh.

#### close() : void

Closes the component and resets transient state used while visible.

#### toggle() : void

Toggles the component between open and closed states, often preserving or selecting a requested section.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Starts external commands through Quickshell process helpers or `Process` objects.

Exposes IPC targets: `kitana-wallpaper`.
