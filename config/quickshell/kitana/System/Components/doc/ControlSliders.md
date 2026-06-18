# Control Sliders

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable system panel controls and rows area.

ControlSliders is a reusable System component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `System/Components/ControlSliders.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`, `import "../../Services" as Services`.

Referenced or instantiated by: `System/SystemPanel.qml`.

## Component Hierarchy and Role

The root type is `Column`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| None | - | - | No | This component declares no root-level custom properties. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.SystemStatus`.
