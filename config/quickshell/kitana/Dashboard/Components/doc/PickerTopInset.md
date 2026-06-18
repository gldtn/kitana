# Picker Top Inset

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable dashboard rows, buttons, fields, and picker helpers area.

PickerTopInset is a reusable Dashboard component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `Dashboard/Components/PickerTopInset.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`.

Referenced or instantiated by: `Dashboard/Tabs/ThemesTab.qml`, `Dashboard/Tabs/WallpapersTab.qml`.

## Component Hierarchy and Role

The root type is `Item`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| None | - | - | No | This component declares no root-level custom properties. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.
