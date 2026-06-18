# Osd Service

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the Quickshell singleton services and process-backed state adapters area.

OsdService is a singleton service in the Services module that exposes shared state or command helpers to the rest of the shell.

## Project Structure and Dependencies

Source file: `Services/OsdService.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`.

Project imports: `import ".."`.

Referenced or instantiated by: `OSD/OsdPopup.qml`, `shell.qml`.

## Component Hierarchy and Role

The root type is `Singleton`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `popupVisible` | `bool` | `false` | No | Enables or disables the `popupVisible` state. |
| `kind` | `string` | `"volume"` | No | Stores the string value for `kind`. |
| `title` | `string` | `"Volume"` | No | Stores the primary label shown by the component. |
| `value` | `int` | `0` | No | Controls the numeric value for `value`. |
| `muted` | `bool` | `false` | No | Enables or disables the `muted` state. |
| `visible` | `readonly bool` | `popupVisible` | No | Read-only. Exposes whether the component or service is currently visible. |
| `iconName` | `readonly string` | `{` | No | Read-only. Selects a semantic icon token from the Kitana icon registry. |

## Methods

#### show(nextKind, nextTitle, nextValue, nextMuted) : void

Performs component-specific behavior used internally or by parent components.

#### showPayload(payload) : void

Performs component-specific behavior used internally or by parent components.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.
