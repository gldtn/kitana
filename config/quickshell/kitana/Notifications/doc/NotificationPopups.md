# Notification Popups

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the notification popup presentation area.

NotificationPopups is a layer-shell panel window in the Notifications module.

## Project Structure and Dependencies

Source file: `Notifications/NotificationPopups.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`, `import Quickshell.Wayland`.

Project imports: `import ".."`, `import "../Components/Controls" as Controls`, `import "../custom" as Custom`, `import "../Services" as Services`.

Referenced or instantiated by: `Bar/BarWindow.qml`.

## Component Hierarchy and Role

The root type is `PanelWindow`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `panelScreen` | `var` | `null` | No | Selects the Quickshell screen or monitor that owns this window or bar instance. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.NotificationService`.

Starts external commands through Quickshell process helpers or `Process` objects.
