// Kitana managed Quickshell colors

pragma Singleton

import QtQuick

QtObject {

  function colorChannel(color: string): string {
    return color.startsWith("#") ? color.slice(1) : color;
  }

  function alpha(percent: real): string {
    const value = Math.max(0, Math.min(255, Math.round(255 * percent / 100)));
    return value.toString(16).padStart(2, "0");
  }

  function withAlpha(color: string, opacity): string {
    const value = typeof opacity === "number" ? alpha(opacity) : opacity;
    return "#" + value + colorChannel(color);
  }

  function alphaColor(rgb: string, percent: real): string {
    return withAlpha(rgb, percent);
  }

  // Canonical foreground roles.
  readonly property color foreground: "#cdd6f4"
  readonly property color foregroundStrong: "#f5e0dc"
  readonly property color foregroundMuted: "#9399b2"
  readonly property color foregroundSubtle: "#9399b2"
  readonly property color foregroundDisabled: withAlpha(foregroundMuted, 50)
  readonly property color foregroundInverted: "#181825"

  // Canonical accent roles.
  readonly property color accent: "#cba6f7"
  readonly property color accentStrong: "#b4befe"
  readonly property color foregroundOnAccent: "#181825"
  readonly property color accentBackground: withAlpha(accent, 20)
  readonly property color accentSelectedBackground: withAlpha(accent, 30)

  // Canonical surface roles.
  readonly property color background: "#1e1e2e"
  readonly property color surface: "#181825"
  readonly property color surfaceContainer: "#181825"
  readonly property color surfaceCard: "#313244"
  readonly property color surfaceControl: "#313244"
  readonly property color surfaceSubtle: "#45475a"
  readonly property color surfaceHover: "#45475a"
  readonly property color surfacePressed: "#45475a"
  readonly property color surfaceActive: "#cba6f7"
  readonly property color surfaceSelected: "#cba6f7"
  readonly property color surfaceFloating: "#1e1e2e"
  readonly property color surfaceFloatingStrong: "#313244"

  // Canonical border roles.
  readonly property color border: "#313244"
  readonly property color borderSubtle: "#313244"
  readonly property color borderMuted: "#45475a"
  readonly property color borderStrong: "#45475a"
  readonly property color borderFocus: "#cba6f7"

  // Canonical status roles.
  readonly property color info: "#89b4fa"
  readonly property color success: "#a6e3a1"
  readonly property color warning: "#f9e2af"
  readonly property color danger: "#f38ba8"
  readonly property color infoBackground: withAlpha(info, 20)
  readonly property color successBackground: withAlpha(success, 20)
  readonly property color warningBackground: withAlpha(warning, 20)
  readonly property color dangerBackground: withAlpha(danger, 20)

  // Permanent icon foreground roles used by Config/Icons.qml tone mapping.
  readonly property color iconPrimary: "#cdd6f4"
  readonly property color iconSecondary: "#f5e0dc"
  readonly property color iconMuted: "#9399b2"
  readonly property color iconSubtle: "#9399b2"
  readonly property color iconAccent: "#cba6f7"
  readonly property color iconOnAccent: "#181825"
  readonly property color iconInverse: "#181825"
  readonly property color iconBrand: "#cba6f7"
  readonly property color iconDisabled: withAlpha("#9399b2", 50)
  readonly property color iconDanger: "#f38ba8"

  // Shallow Kitana component roles. Keep these independently defined for future per-component tuning.
  readonly property color barBackground: withAlpha(background, 92)
  readonly property color barForeground: foreground
  readonly property color barHoverBackground: withAlpha(surfaceHover, 93)
  readonly property color barBorder: withAlpha(borderMuted, 25)

  readonly property color panelBackground: withAlpha(background, 98)
  readonly property color panelForeground: foreground
  readonly property color panelBorder: border

  readonly property color containerBackground: withAlpha(surfaceContainer, 96)
  readonly property color containerForeground: foreground
  readonly property color containerBorder: borderMuted

  readonly property color cardBackground: withAlpha(surfaceCard, 68)
  readonly property color cardForeground: foreground
  readonly property color cardBorder: border

  readonly property color controlBackground: surfaceControl
  readonly property color controlButtonBackground: "transparent"
  readonly property color controlForeground: foreground
  readonly property color controlBorder: border
  readonly property color controlSubtleBackground: surfaceSubtle
  readonly property color controlHoverBackground: withAlpha(surfaceHover, 75)
  readonly property color controlButtonHoverBackground: withAlpha(surfaceContainer, 65)
  readonly property color controlPressedBackground: withAlpha(surfacePressed, 96)
  readonly property color controlActiveBackground: withAlpha(surfaceActive, 25)
  readonly property color controlActiveForeground: foreground
  readonly property color controlActiveBorder: withAlpha(borderFocus, 60)

  // Floating elements (OSD, Notifications)
  readonly property color popupBackground: withAlpha(surfaceFloatingStrong, 65)
  readonly property color popupForeground: foreground
  readonly property color popupForegroundMuted: foregroundMuted
  readonly property color popupSurface: withAlpha(surfaceControl, 80)
  readonly property color popupBorder: borderMuted

  readonly property color inputBackground: withAlpha(surfaceControl, 80)
  readonly property color inputForeground: foreground
  readonly property color inputPlaceholderForeground: foregroundMuted
  readonly property color inputBorder: borderMuted
  readonly property color inputActiveBorder: borderFocus

  readonly property color workspaceInactiveBackground: withAlpha(surfaceSubtle, 45)
  readonly property color workspaceInactiveForeground: withAlpha(foregroundMuted, 55)
  readonly property color workspaceOccupiedBackground: withAlpha(surfaceSubtle, 90)
  readonly property color workspaceOccupiedForeground: foreground
  readonly property color workspaceActiveBackground: accent
  readonly property color workspaceActiveForeground: foregroundOnAccent
  readonly property color workspaceUrgentBackground: withAlpha(danger, 20)
  readonly property color workspaceUrgentForeground: danger

  // Overlays.
  readonly property color scrim: withAlpha(background, 52)
  readonly property color scrimSoft: withAlpha(background, 32)
  readonly property color imageOverlay: withAlpha(background, 60)
  readonly property color shadow: withAlpha("#000000", 45)
}
