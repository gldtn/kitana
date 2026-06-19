# Header Icon

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable control panel controls and rows area.

HeaderIcon is a reusable System component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `System/Components/HeaderIcon.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`.

Referenced or instantiated by: `System/Components/PanelHeader.qml`.

## Component Hierarchy and Role

The root type is `Controls.Icon`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| None | - | - | No | This component declares no root-level custom properties. |

## Signals

#### clicked()

Emitted by user interaction or component state changes. Connected handlers should respond by updating parent state or invoking the requested action.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.
