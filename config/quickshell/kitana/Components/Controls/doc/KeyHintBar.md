# Key Hint Bar

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the shared reusable controls used across panels and popups area.

KeyHintBar is a reusable Components component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `Components/Controls/KeyHintBar.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Launcher/AppLauncher.qml`, `Shortcuts/ShortcutsPanel.qml`.

## Component Hierarchy and Role

The root type is `Text`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `hints` | `string` | `""` | No | Stores the string value for `hints`. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
KeyHintBar {
}
```
