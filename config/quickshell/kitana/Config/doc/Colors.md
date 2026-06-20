# Colors

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the singleton design tokens for colors, icons, and typography area.

Colors is a singleton configuration object that provides shared design tokens or user-facing settings.

## Project Structure and Dependencies

Source file: `Config/Colors.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`, `import Quickshell.Io`.

Referenced or instantiated by: `Bar/BarWindow.qml`, `Bar/Items/ControlCluster.qml`, `Bar/Items/DateTime.qml`, `Bar/Items/Layout.qml`, `Bar/Items/Screenshot.qml`, `Bar/Items/Session.qml`, `Bar/Items/Start.qml`, `Bar/Items/Workspaces.qml`, `Bar/StartMenu.qml`, `Components/Controls/BlurredBackdrop.qml`, `Components/Controls/KeyHintBar.qml`, `Components/Controls/PanelRow.qml`.

## Component Hierarchy and Role

The root type is `QtObject`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `foreground` | `readonly color` | `"#cdd6f4"` | No | Read-only. Provides the color value used by `foreground` styling. |
| `foregroundStrong` | `readonly color` | `"#f5e0dc"` | No | Read-only. Provides the color value used by `foregroundStrong` styling. |
| `foregroundMuted` | `readonly color` | `"#9399b2"` | No | Read-only. Provides the color value used by `foregroundMuted` styling. |
| `foregroundSubtle` | `readonly color` | `"#9399b2"` | No | Read-only. Provides the color value used by `foregroundSubtle` styling. |
| `foregroundDisabled` | `readonly color` | `withAlpha(foregroundMuted, 50)` | No | Read-only. Provides the color value used by `foregroundDisabled` styling. |
| `foregroundInverted` | `readonly color` | `"#181825"` | No | Read-only. Provides the color value used by `foregroundInverted` styling. |
| `accent` | `readonly color` | `"#cba6f7"` | No | Read-only. Provides the primary accent color token. |
| `accentStrong` | `readonly color` | `"#b4befe"` | No | Read-only. Provides the color value used by `accentStrong` styling. |
| `foregroundOnAccent` | `readonly color` | `"#181825"` | No | Read-only. Provides the color value used by `foregroundOnAccent` styling. |
| `accentBackground` | `readonly color` | `withAlpha(accent, 20)` | No | Read-only. Provides the color value used by `accentBackground` styling. |
| `accentSelectedBackground` | `readonly color` | `withAlpha(accent, 30)` | No | Read-only. Provides the color value used by `accentSelectedBackground` styling. |
| `background` | `readonly color` | `"#1e1e2e"` | No | Read-only. Provides the base background color token. |
| `surface` | `readonly color` | `"#181825"` | No | Read-only. Provides the color value used by `surface` styling. |
| `surfaceContainer` | `readonly color` | `"#181825"` | No | Read-only. Provides the color value used by `surfaceContainer` styling. |
| `surfaceCard` | `readonly color` | `"#313244"` | No | Read-only. Provides the color value used by `surfaceCard` styling. |
| `surfaceControl` | `readonly color` | `"#313244"` | No | Read-only. Provides the color value used by `surfaceControl` styling. |
| `surfaceSubtle` | `readonly color` | `"#45475a"` | No | Read-only. Provides the color value used by `surfaceSubtle` styling. |
| `surfaceHover` | `readonly color` | `"#45475a"` | No | Read-only. Provides the color value used by `surfaceHover` styling. |
| `surfacePressed` | `readonly color` | `"#45475a"` | No | Read-only. Provides the color value used by `surfacePressed` styling. |
| `surfaceActive` | `readonly color` | `"#cba6f7"` | No | Read-only. Provides the color value used by `surfaceActive` styling. |
| `surfaceSelected` | `readonly color` | `"#cba6f7"` | No | Read-only. Provides the color value used by `surfaceSelected` styling. |
| `surfaceFloating` | `readonly color` | `"#1e1e2e"` | No | Read-only. Provides the color value used by `surfaceFloating` styling. |
| `surfaceFloatingStrong` | `readonly color` | `"#313244"` | No | Read-only. Provides the color value used by `surfaceFloatingStrong` styling. |
| `border` | `readonly color` | `"#313244"` | No | Read-only. Provides the color value used by `border` styling. |
| `borderSubtle` | `readonly color` | `"#313244"` | No | Read-only. Provides the color value used by `borderSubtle` styling. |
| `borderMuted` | `readonly color` | `"#45475a"` | No | Read-only. Provides the color value used by `borderMuted` styling. |
| `borderStrong` | `readonly color` | `"#45475a"` | No | Read-only. Provides the color value used by `borderStrong` styling. |
| `borderFocus` | `readonly color` | `"#cba6f7"` | No | Read-only. Provides the color value used by `borderFocus` styling. |
| `info` | `readonly color` | `"#89b4fa"` | No | Read-only. Provides the color value used by `info` styling. |
| `success` | `readonly color` | `"#a6e3a1"` | No | Read-only. Provides the color value used by `success` styling. |
| `warning` | `readonly color` | `"#f9e2af"` | No | Read-only. Provides the color value used by `warning` styling. |
| `danger` | `readonly color` | `"#f38ba8"` | No | Read-only. Provides the color value used by `danger` styling. |
| `infoBackground` | `readonly color` | `withAlpha(info, 20)` | No | Read-only. Provides the color value used by `infoBackground` styling. |
| `successBackground` | `readonly color` | `withAlpha(success, 20)` | No | Read-only. Provides the color value used by `successBackground` styling. |
| `warningBackground` | `readonly color` | `withAlpha(warning, 20)` | No | Read-only. Provides the color value used by `warningBackground` styling. |
| `dangerBackground` | `readonly color` | `withAlpha(danger, 20)` | No | Read-only. Provides the color value used by `dangerBackground` styling. |
| `iconPrimary` | `readonly color` | `"#cdd6f4"` | No | Read-only. Provides the color value used by `iconPrimary` styling. |
| `iconSecondary` | `readonly color` | `"#f5e0dc"` | No | Read-only. Provides the color value used by `iconSecondary` styling. |
| `iconMuted` | `readonly color` | `"#9399b2"` | No | Read-only. Provides the color value used by `iconMuted` styling. |
| `iconSubtle` | `readonly color` | `"#9399b2"` | No | Read-only. Provides the color value used by `iconSubtle` styling. |
| `iconAccent` | `readonly color` | `"#cba6f7"` | No | Read-only. Provides the color value used by `iconAccent` styling. |
| `iconOnAccent` | `readonly color` | `"#181825"` | No | Read-only. Provides the color value used by `iconOnAccent` styling. |
| `iconInverse` | `readonly color` | `"#181825"` | No | Read-only. Provides the color value used by `iconInverse` styling. |
| `iconBrand` | `readonly color` | `"#cba6f7"` | No | Read-only. Provides the color value used by `iconBrand` styling. |
| `iconDisabled` | `readonly color` | `withAlpha("#9399b2", 50)` | No | Read-only. Provides the color value used by `iconDisabled` styling. |
| `iconDanger` | `readonly color` | `"#f38ba8"` | No | Read-only. Provides the color value used by `iconDanger` styling. |
| `barBackground` | `readonly color` | `withAlpha(background, 96)` | No | Read-only. Provides the color value used by `barBackground` styling. |
| `barForeground` | `readonly color` | `foreground` | No | Read-only. Provides the color value used by `barForeground` styling. |
| `barHoverBackground` | `readonly color` | `withAlpha(surfaceHover, 93)` | No | Read-only. Provides the color value used by `barHoverBackground` styling. |
| `barBorder` | `readonly color` | `withAlpha(borderMuted, 25)` | No | Read-only. Provides the color value used by `barBorder` styling. |
| `panelBackground` | `readonly color` | `withAlpha(background, 98)` | No | Read-only. Provides the color value used by `panelBackground` styling. |
| `panelForeground` | `readonly color` | `foreground` | No | Read-only. Provides the color value used by `panelForeground` styling. |
| `panelBorder` | `readonly color` | `border` | No | Read-only. Provides the color value used by `panelBorder` styling. |
| `containerBackground` | `readonly color` | `withAlpha(surfaceContainer, 96)` | No | Read-only. Provides the color value used by `containerBackground` styling. |
| `containerForeground` | `readonly color` | `foreground` | No | Read-only. Provides the color value used by `containerForeground` styling. |
| `containerBorder` | `readonly color` | `withAlpha(borderMuted, 65)` | No | Read-only. Provides the color value used by `containerBorder` styling. |
| `cardBackground` | `readonly color` | `withAlpha(surfaceCard, 68)` | No | Read-only. Provides the color value used by `cardBackground` styling. |
| `cardForeground` | `readonly color` | `foreground` | No | Read-only. Provides the color value used by `cardForeground` styling. |
| `cardBorder` | `readonly color` | `border` | No | Read-only. Provides the color value used by `cardBorder` styling. |
| `controlBackground` | `readonly color` | `surfaceControl` | No | Read-only. Provides the color value used by `controlBackground` styling. |
| `controlButtonBackground` | `readonly color` | `"transparent"` | No | Read-only. Provides the color value used by `controlButtonBackground` styling. |
| `controlForeground` | `readonly color` | `foreground` | No | Read-only. Provides the color value used by `controlForeground` styling. |
| `controlBorder` | `readonly color` | `withAlpha(borderStrong, 45)` | No | Read-only. Provides the color value used by `controlBorder` styling. |
| `controlSubtleBorder` | `readonly color` | `withAlpha(borderSubtle, 65)` | No | Read-only. Provides the color value used by `controlSubtleBorder` styling. |
| `controlSubtleBackground` | `readonly color` | `surfaceSubtle` | No | Read-only. Provides the color value used by `controlSubtleBackground` styling. |
| `controlHoverBackground` | `readonly color` | `withAlpha(surfaceHover, 75)` | No | Read-only. Provides the color value used by `controlHoverBackground` styling. |
| `controlButtonHoverBackground` | `readonly color` | `withAlpha(surfaceContainer, 65)` | No | Read-only. Provides the color value used by `controlButtonHoverBackground` styling. |
| `controlPressedBackground` | `readonly color` | `withAlpha(surfacePressed, 96)` | No | Read-only. Provides the color value used by `controlPressedBackground` styling. |
| `controlActiveBackground` | `readonly color` | `withAlpha(surfaceActive, 25)` | No | Read-only. Provides the color value used by `controlActiveBackground` styling. |
| `controlActiveForeground` | `readonly color` | `foreground` | No | Read-only. Provides the color value used by `controlActiveForeground` styling. |
| `controlActiveBorder` | `readonly color` | `withAlpha(borderFocus, 50)` | No | Read-only. Provides the color value used by `controlActiveBorder` styling. |
| `popupBackground` | `readonly color` | `withAlpha(surfaceFloatingStrong, 90)` | No | Read-only. Provides the color value used by `popupBackground` styling. |
| `popupForeground` | `readonly color` | `foreground` | No | Read-only. Provides the color value used by `popupForeground` styling. |
| `popupForegroundMuted` | `readonly color` | `foregroundMuted` | No | Read-only. Provides the color value used by `popupForegroundMuted` styling. |
| `popupSurface` | `readonly color` | `surfaceControl` | No | Read-only. Provides the color value used by `popupSurface` styling. |
| `popupBorder` | `readonly color` | `borderMuted` | No | Read-only. Provides the color value used by `popupBorder` styling. |
| `inputBg` | `readonly color` | `{ ref: "bgSecondary", lighten: 0.03 }` | No | QML-only shared text input background composition role. |
| `inputFg` | `readonly color` | `fgPrimary` | No | QML-only shared text input foreground composition role. |
| `inputPlaceholderFg` | `readonly color` | `fgSecondary` | No | QML-only shared placeholder foreground composition role. |
| `inputBorder` | `readonly color` | `borderFaint` | No | QML-only shared idle text input border composition role. |
| `inputBorderFocus` | `readonly color` | `{ ref: "borderAccent", alpha: 0.16 }` | No | QML-only shared focused text input border composition role. |
| `inputSelection` | `readonly color` | `subtleAccent` | No | QML-only shared text selection background composition role. |
| `inputSelectedFg` | `readonly color` | `fgPrimary` | No | QML-only shared selected text foreground composition role. |
| `barItemBg` | `readonly color` | `bgPrimary` | No | QML-only top-bar item background composition role. |
| `barItemBorder` | `readonly color` | `borderFaint` | No | QML-only top-bar item border composition role. |
| `barItemFg` | `readonly color` | `fgPrimary` | No | QML-only top-bar item text foreground composition role. |
| `workspaceInactiveBackground` | `readonly color` | `withAlpha(surfaceSubtle, 45)` | No | Read-only. Provides the color value used by `workspaceInactiveBackground` styling. |
| `workspaceInactiveForeground` | `readonly color` | `withAlpha(foregroundMuted, 55)` | No | Read-only. Provides the color value used by `workspaceInactiveForeground` styling. |
| `workspaceOccupiedBackground` | `readonly color` | `withAlpha(surfaceSubtle, 90)` | No | Read-only. Provides the color value used by `workspaceOccupiedBackground` styling. |
| `workspaceOccupiedForeground` | `readonly color` | `foreground` | No | Read-only. Provides the color value used by `workspaceOccupiedForeground` styling. |
| `workspaceActiveBackground` | `readonly color` | `accent` | No | Read-only. Provides the color value used by `workspaceActiveBackground` styling. |
| `workspaceActiveForeground` | `readonly color` | `foregroundOnAccent` | No | Read-only. Provides the color value used by `workspaceActiveForeground` styling. |
| `workspaceUrgentBackground` | `readonly color` | `withAlpha(danger, 20)` | No | Read-only. Provides the color value used by `workspaceUrgentBackground` styling. |
| `workspaceUrgentForeground` | `readonly color` | `danger` | No | Read-only. Provides the color value used by `workspaceUrgentForeground` styling. |
| `scrim` | `readonly color` | `withAlpha(background, 52)` | No | Read-only. Provides the color value used by `scrim` styling. |
| `scrimSoft` | `readonly color` | `withAlpha(background, 32)` | No | Read-only. Provides the color value used by `scrimSoft` styling. |
| `imageOverlay` | `readonly color` | `withAlpha(background, 60)` | No | Read-only. Provides the color value used by `imageOverlay` styling. |
| `shadow` | `readonly color` | `withAlpha("#000000", 45)` | No | Read-only. Provides the color value used by `shadow` styling. |

## Methods

#### colorChannel(color: string) : string

Performs component-specific behavior used internally or by parent components.

#### alpha(percent: real) : string

Performs component-specific behavior used internally or by parent components.

#### withAlpha(color: string, opacity) : string

Performs component-specific behavior used internally or by parent components.

#### alphaColor(rgb: string, percent: real) : string

Performs component-specific behavior used internally or by parent components.

#### composeColor(value: var, fallback: var) : string

Resolves a QML composition color using the same ref, mix, lighten, darken, and alpha object syntax as theme palettes.

#### themedColor(variants: var, fallback: var) : string

Resolves a QML composition color from a `theme.slug`, `mode`, or `default` entry for local per-theme tuning without adding palette roles.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.
