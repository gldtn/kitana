# Notifications Pane

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the control panel detail panes for audio, Bluetooth, network, notifications, settings, and session actions area.

NotificationsPane is a detail pane in the control panel.

## Project Structure and Dependencies

Source file: `System/Panes/NotificationsPane.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`, `import "../Components"`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`, `import "../../Services" as Services`.

Referenced or instantiated by: `System/ControlPanel.qml`.

## Component Hierarchy and Role

The root type is `Item`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| None | - | - | No | This component declares no root-level custom properties. |

## Signals

#### clicked()

Emitted by user interaction or component state changes. Connected handlers should respond by updating parent state or invoking the requested action.


## Inline Components

| Component | Base Type | Description |
|-----------|-----------|-------------|
| `FooterAction` | `Item` | Inline helper component local to this file. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.NotificationService`.
