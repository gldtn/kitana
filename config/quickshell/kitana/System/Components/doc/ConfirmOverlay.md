# Confirm Overlay

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable control panel controls and rows area.

ConfirmOverlay is a reusable System component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `System/Components/ConfirmOverlay.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`, `import "../../custom" as Custom`.

No direct QML instantiations were found; the component is an entrypoint, singleton, or loaded indirectly.

## Component Hierarchy and Role

The root type is `Rectangle`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `panel` | `var` | `null` | No | Provides component state or configuration for `panel`. |
| `confirming` | `readonly bool` | `panel && panel.confirmAction.length > 0` | No | Read-only. Enables or disables the `confirming` state. |

## Inter-Component Interactions

Interactions are limited to parent bindings, local child composition, and shared design token imports.

## Usage Example

```qml
ConfirmOverlay {
}
```
