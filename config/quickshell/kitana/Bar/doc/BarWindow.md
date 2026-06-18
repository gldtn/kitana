# Bar Window

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the per-monitor top bar windows and start menu overlays area.

BarWindow is a layer-shell panel window in the Bar module.

## Project Structure and Dependencies

Source file: `Bar/BarWindow.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`, `import Quickshell.Wayland`.

Project imports: `import ".."`, `import "../custom" as Custom`, `import "../Notifications" as Notifications`, `import "../OSD" as OSD`, `import "../Services" as Services`, `import "../System" as System`, `import "./Sections" as Sections`.

Referenced or instantiated by: `shell.qml`.

## Component Hierarchy and Role

The root type is `PanelWindow`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `panelScreen` | `var` | `null` | No | Selects the Quickshell screen or monitor that owns this window or bar instance. |
| `barVisible` | `bool` | `true` | No | Controls whether the top bar is shown and reserves exclusive screen space. |
| `dashboardPanel` | `var` | `null` | No | Receives the shared dashboard panel instance used by bar controls to open dashboard tabs. |
| `screenshotPanel` | `var` | `null` | No | Receives the shared screenshot panel instance used to open or toggle capture controls. |
| `settingsPanel` | `var` | `null` | No | Receives the shared settings panel instance used by menu actions. |
| `shortcutsPanel` | `var` | `null` | No | Receives the shared shortcuts panel instance used by menu actions. |
| `sectionGap` | `readonly int` | `settings.rowSpacing` | No | Read-only. Controls the numeric value for `sectionGap`. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.CaffeineService`.
