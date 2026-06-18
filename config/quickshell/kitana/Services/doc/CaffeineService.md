# Caffeine Service

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the Quickshell singleton services and process-backed state adapters area.

CaffeineService is a singleton service in the Services module that exposes shared state or command helpers to the rest of the shell.

## Project Structure and Dependencies

Source file: `Services/CaffeineService.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`.

Project imports: `import ".."`.

Referenced or instantiated by: `Bar/BarWindow.qml`, `Settings/SettingsPanel.qml`, `System/Components/QuickSettingsGrid.qml`.

## Component Hierarchy and Role

The root type is `Singleton`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `enabled` | `alias` | `state.enabled` | No | Controls whether the feature or service is active. |
| `iconName` | `readonly string` | `Icons.caffeineName(enabled)` | No | Read-only. Selects a semantic icon token from the Kitana icon registry. |
| `subtitle` | `readonly string` | `enabled ? "On" : "Off"` | No | Read-only. Stores secondary explanatory text shown by the component. |

## Methods

#### toggle() : void

Toggles the component between open and closed states, often preserving or selecting a requested section.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.
