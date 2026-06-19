# Audio Pane

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the control panel detail panes for audio, Bluetooth, network, notifications, settings, and session actions area.

AudioPane is a detail pane in the control panel.

## Project Structure and Dependencies

Source file: `System/Panes/AudioPane.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`, `import "../Components"`, `import "../../custom" as Custom`, `import "../../Services" as Services`.

Referenced or instantiated by: `System/ControlPanel.qml`.

## Component Hierarchy and Role

The root type is `Flickable`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| None | - | - | No | This component declares no root-level custom properties. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.SystemStatus`.
