# Ui Preferences

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the Quickshell singleton services and process-backed state adapters area.

UiPreferences is a singleton service in the Services module that exposes shared state or command helpers to the rest of the shell.

## Project Structure and Dependencies

Source file: `Services/UiPreferences.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`.

Project imports: `import "../custom" as Custom`.

Referenced or instantiated by: bar windows and items, dashboard island geometry, notification/control popups, and `Settings/SettingsPanel.qml`.

## Component Hierarchy and Role

The root type is `Singleton`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `layoutPillDisplayMode` | `alias` | `state.layoutPillDisplayMode` | No | Exposes an internal child property through the `layoutPillDisplayMode` alias. |
| `panelHeightPreference` | `alias` | `state.panelHeight` | No | Raw persisted bar height override; `0` means use the custom settings default. |
| `pillHeightPreference` | `alias` | `state.pillHeight` | No | Raw persisted bar pill height override; `0` means use the custom settings default. |
| `topMarginPreference` | `alias` | `state.topMargin` | No | Raw persisted top margin override; `-1` means use the custom settings default. |
| `pillRadiusPreference` | `alias` | `state.pillRadius` | No | Raw persisted pill radius override; `-1` means use the custom settings default. |
| `layoutPillDisplayModes` | `readonly var` | `["icons", "compact", "full"]` | No | Read-only. Provides component state or configuration for `layoutPillDisplayModes`. |
| `defaultPanelHeight` | `readonly int` | `defaults.panelHeight` | No | Fallback bar height from `custom.Settings`. |
| `defaultPillHeight` | `readonly int` | `defaults.pillHeight` | No | Fallback bar pill height from `custom.Settings`. |
| `defaultTopMargin` | `readonly int` | `defaults.topMargin` | No | Fallback top margin from `custom.Settings`. |
| `defaultPillRadius` | `readonly int` | `Math.round(defaults.pillHeight / defaults.radiusDivisor)` | No | Fallback bar pill radius derived from `custom.Settings`. |
| `panelHeight` | `readonly int` | Resolved preference/default | No | Clamped live bar height. |
| `barHeight` | `readonly int` | `panelHeight` | No | Alias-style resolved bar height for consumers that describe the same geometry differently. |
| `exclusiveZone` | `readonly int` | `panelHeight` | No | Reserved layer-shell edge height matching the resolved bar height. |
| `pillHeight` | `readonly int` | Resolved preference/default | No | Clamped live bar pill height. |
| `topMargin` | `readonly int` | Resolved preference/default | No | Clamped live top margin from the screen edge. |
| `pillRadius` | `readonly int` | Resolved preference/default | No | Clamped live bar pill radius. |
| `clockHorizontalPadding` | `readonly int` | `defaults.clockHorizontalPadding` | No | Horizontal padding used by the center date/time island. |
| `statusHorizontalPadding` | `readonly int` | `defaults.statusHorizontalPadding` | No | Horizontal padding used by the right status cluster. |
| `workspaceHorizontalPadding` | `readonly int` | `defaults.workspaceHorizontalPadding` | No | Reserved workspace padding value from defaults. |

## Methods

#### resolvedInt(value: int, fallback: int, minimum: int, maximum: int) : int

Clamps numeric preference values, falling back when the stored value is outside the valid range.

#### setPanelHeight(value: int) : void

Persists a clamped bar height and keeps the stored pill height no taller than the bar.

#### setPillHeight(value: int) : void

Persists a clamped pill height and keeps the stored radius no larger than half the pill height.

#### setTopMargin(value: int) : void

Persists a clamped top margin.

#### setPillRadius(value: int) : void

Persists a clamped bar pill radius.

#### resetBarGeometry() : void

Clears stored bar geometry overrides so resolved values return to `custom.Settings` defaults.

#### setLayoutPillDisplayMode(mode: string) : void

Performs component-specific behavior used internally or by parent components.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.
