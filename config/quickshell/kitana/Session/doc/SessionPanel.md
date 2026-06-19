# Session Panel

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the session and power action panel area.

SessionPanel is a layer-shell panel window in the Session module.

## Project Structure and Dependencies

Source file: `Session/SessionPanel.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`, `import Quickshell`, `import Quickshell.Io`, `import Quickshell.Wayland`.

Project imports: `import ".."`, `import "../Components/Controls" as Controls`, `import "../custom" as Custom`.

Referenced or instantiated by: `shell.qml`.

## Component Hierarchy and Role

The root type is `PanelWindow`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

The session header uses `Controls.CloseButton` for explicit dismissal.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `panelVisible` | `bool` | `false` | No | Tracks whether the panel window should be visible. |
| `confirmAction` | `string` | `""` | No | Stores the string value for `confirmAction`. |
| `confirmTitle` | `string` | `""` | No | Stores the string value for `confirmTitle`. |
| `kitanaDir` | `string` | `Quickshell.env("KITANA_DIR") \|\| Quickshell.env("HOME") + "/.local/share/kitana"` | No | Stores the Kitana repository path used to call helper commands. |

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

#### ask(action: string, title: string) : void

Performs component-specific behavior used internally or by parent components.

#### lockSession() : void

Performs component-specific behavior used internally or by parent components.

#### runConfirmedAction() : void

Performs component-specific behavior used internally or by parent components.

#### handleKey(event: var) : void

Performs component-specific behavior used internally or by parent components.


## Inline Components

| Component | Base Type | Description |
|-----------|-----------|-------------|
| `SessionAction` | `Rectangle` | Inline helper component local to this file. |
| `ConfirmButton` | `Rectangle` | Inline helper component local to this file. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Starts external commands through Quickshell process helpers or `Process` objects.

Exposes IPC targets: `kitana-session`.
