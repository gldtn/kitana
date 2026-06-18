# Settings Panel

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the settings panel for shell preferences area.

SettingsPanel is a layer-shell panel window in the Settings module.

## Project Structure and Dependencies

Source file: `Settings/SettingsPanel.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`, `import Quickshell`, `import Quickshell.Io`, `import Quickshell.Wayland`.

Project imports: `import ".."`, `import "../Components/Controls" as Controls`, `import "../Services" as Services`, `import "../custom" as Custom`.

Referenced or instantiated by: `shell.qml`.

## Component Hierarchy and Role

The root type is `PanelWindow`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `panelVisible` | `bool` | `false` | No | Tracks whether the panel window should be visible. |
| `revealProgress` | `real` | `0` | No | Controls the numeric value for `revealProgress`. |
| `activeTab` | `string` | `"bar"` | No | Tracks which tab is currently selected. |

## Signals

#### clicked()

Emitted by user interaction or component state changes. Connected handlers should respond by updating parent state or invoking the requested action.


## Methods

#### open(tab: string) : void

Opens the component or switches it to the requested section/tab. Side effects usually include focus changes, state reset, or data refresh.

#### close() : void

Closes the component and resets transient state used while visible.

#### toggle(tab: string) : void

Toggles the component between open and closed states, often preserving or selecting a requested section.

#### modeTitle(mode: string) : string

Performs component-specific behavior used internally or by parent components.

#### modeSubtitle(mode: string) : string

Performs component-specific behavior used internally or by parent components.


## Inline Components

| Component | Base Type | Description |
|-----------|-----------|-------------|
| `TabButton` | `Rectangle` | Inline helper component local to this file. |
| `SettingRow` | `Rectangle` | Inline helper component local to this file. |
| `OptionButton` | `Rectangle` | Inline helper component local to this file. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.CaffeineService`, `Services.NotificationService`, `Services.UiPreferences`.

Exposes IPC targets: `kitana-settings`.
