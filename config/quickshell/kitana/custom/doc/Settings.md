# Settings

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the user-facing settings singleton copied once and preserved area.

Settings is a singleton configuration object that provides shared design tokens or user-facing settings.

## Project Structure and Dependencies

Source file: `custom/Settings.qml`.

Qt and Quickshell imports: `import QtQuick`.

Referenced or instantiated by: `Bar/BarWindow.qml`, `Bar/Items/ControlCluster.qml`, `Bar/Items/DateTime.qml`, `Bar/Items/Layout.qml`, `Bar/Items/Screenshot.qml`, `Bar/Items/Session.qml`, `Bar/Items/Start.qml`, `Bar/Items/Workspaces.qml`, `Bar/StartMenu.qml`, `Components/Controls/Icon.qml`, `Components/Controls/KeyHintBar.qml`, `Components/Controls/PanelRow.qml`.

## Component Hierarchy and Role

The root type is `QtObject`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `fontFamily` | `readonly string` | `"JetBrainsMono Nerd Font Propo"` | No | Read-only. Stores the string value for `fontFamily`. |
| `panelHeight` | `readonly int` | `34` | No | Read-only. Controls the numeric value for `panelHeight`. |
| `exclusiveZone` | `readonly int` | `34` | No | Read-only. Controls the numeric value for `exclusiveZone`. |
| `topMargin` | `readonly int` | `4` | No | Read-only. Controls the numeric value for `topMargin`. |
| `sideMargin` | `readonly int` | `6` | No | Read-only. Controls the numeric value for `sideMargin`. |
| `rowSpacing` | `readonly int` | `10` | No | Read-only. Controls the numeric value for `rowSpacing`. |
| `pillHeight` | `readonly int` | `32` | No | Read-only. Controls the numeric value for `pillHeight`. |
| `radiusDivisor` | `readonly int` | `4` | No | Read-only. Controls the numeric value for `radiusDivisor`. |
| `borderWidth` | `readonly int` | `1` | No | Read-only. Controls the numeric value for `borderWidth`. |
| `clockHorizontalPadding` | `readonly int` | `26` | No | Read-only. Controls the numeric value for `clockHorizontalPadding`. |
| `statusHorizontalPadding` | `readonly int` | `22` | No | Read-only. Controls the numeric value for `statusHorizontalPadding`. |
| `workspaceHorizontalPadding` | `readonly int` | `12` | No | Read-only. Controls the numeric value for `workspaceHorizontalPadding`. |
| `textPixelSize` | `readonly int` | `12` | No | Read-only. Controls the numeric value for `textPixelSize`. |
| `clockPixelSize` | `readonly int` | `13` | No | Read-only. Controls the numeric value for `clockPixelSize`. |
| `iconPixelSize` | `readonly int` | `14` | No | Read-only. Controls the numeric value for `iconPixelSize`. |
| `workspaceActiveWidth` | `readonly int` | `30` | No | Read-only. Controls the numeric value for `workspaceActiveWidth`. |
| `workspaceInactiveWidth` | `readonly int` | `22` | No | Read-only. Controls the numeric value for `workspaceInactiveWidth`. |
| `workspacePillHeight` | `readonly int` | `22` | No | Read-only. Controls the numeric value for `workspacePillHeight`. |
| `workspaceSpacing` | `readonly int` | `6` | No | Read-only. Controls the numeric value for `workspaceSpacing`. |
| `statusSpacing` | `readonly int` | `12` | No | Read-only. Controls the numeric value for `statusSpacing`. |
| `statusItemSpacing` | `readonly int` | `5` | No | Read-only. Controls the numeric value for `statusItemSpacing`. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.
