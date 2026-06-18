# Blurred Backdrop

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the shared reusable controls used across panels and popups area.

BlurredBackdrop is a reusable Components component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `Components/Controls/BlurredBackdrop.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`.

Referenced or instantiated by: `Launcher/AppLauncher.qml`, `Screenshot/ScreenshotPanel.qml`, `Session/SessionPanel.qml`, `Settings/SettingsPanel.qml`, `Shortcuts/ShortcutsPanel.qml`, `Wallpaper/WallpaperGrid.qml`.

## Component Hierarchy and Role

The root type is `Rectangle`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| None | - | - | No | This component declares no root-level custom properties. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.
