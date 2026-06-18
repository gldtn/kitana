# Ui Preferences

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the Quickshell singleton services and process-backed state adapters area.

UiPreferences is a singleton service in the Services module that exposes shared state or command helpers to the rest of the shell.

## Project Structure and Dependencies

Source file: `Services/UiPreferences.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`.

Referenced or instantiated by: `Bar/Items/Layout.qml`, `Settings/SettingsPanel.qml`.

## Component Hierarchy and Role

The root type is `Singleton`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `layoutPillDisplayMode` | `alias` | `state.layoutPillDisplayMode` | No | Exposes an internal child property through the `layoutPillDisplayMode` alias. |
| `layoutPillDisplayModes` | `readonly var` | `["icons", "compact", "full"]` | No | Read-only. Provides component state or configuration for `layoutPillDisplayModes`. |

## Methods

#### setLayoutPillDisplayMode(mode: string) : void

Performs component-specific behavior used internally or by parent components.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.
