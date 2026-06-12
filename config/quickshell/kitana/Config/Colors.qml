// Kitana managed Quickshell colors

pragma Singleton

import QtQuick

QtObject {

  function withAlpha(rgb: string, alpha: string): string {
    return "#" + alpha + rgb;
  }

  function alpha(percent: real): string {
    const value = Math.max(0, Math.min(255, Math.round(255 * percent / 100)));
    return value.toString(16).padStart(2, "0");
  }

  function alphaColor(rgb: string, percent: real): string {
    return withAlpha(rgb, alpha(percent));
  }

  // Raw palette. Suffix 0 is darker, suffix 1 is lighter.
  readonly property string crust0: "11111b"
  readonly property string crust1: "1e1e2e"
  readonly property string mantle0: "181825"
  readonly property string mantle1: "313244"
  readonly property string base0: "1e1e2e"
  readonly property string base1: "313244"
  readonly property string surface0: "313244"
  readonly property string surface1: "45475a"
  readonly property string overlay0: "45475a"
  readonly property string overlay1: "9399b2"
  readonly property string subtext0: "9399b2"
  readonly property string subtext1: "a6adc8"
  readonly property string text0: "cdd6f4"
  readonly property string text1: "ffffff"
  readonly property string accent0: "89b4fa"
  readonly property string accent1: "b4befe"
  readonly property string info0: "89b4fa"
  readonly property string success0: "a6e3a1"
  readonly property string warning0: "f9e2af"
  readonly property string danger0: "f38ba8"

  // Alpha presets for blur-friendly panel layers.
  readonly property string panelAlpha: alpha(92)
  readonly property string panelContainerAlpha: alpha(85)
  readonly property string panelCardAlpha: alpha(60)
  readonly property string panelButtonAlpha: alpha(80)
  readonly property string panelInputAlpha: alpha(80)
  readonly property string scrimAlpha: alpha(52)
  readonly property string scrimSoftAlpha: alpha(32)
  readonly property string imageOverlayAlpha: alpha(60)

  // Semantic foreground and background roles.
  readonly property color accentForeground: "#" + accent0
  readonly property color onAccentForeground: "#" + crust0
  readonly property color primaryForeground: "#" + text0
  readonly property color secondaryForeground: "#" + text1
  readonly property color mutedForeground: "#" + subtext0
  readonly property color accentBackground: "#33" + accent0
  readonly property color primaryBackground: "#" + base0
  readonly property color secondaryBackground: "#" + mantle0
  readonly property color mutedBackground: "#" + crust0

  // Outer dashboard/system/wallpaper picker shell.
  readonly property color panelBackground: withAlpha(mantle0, panelAlpha)
  readonly property color panelForeground: primaryForeground
  readonly property color panelBorder: "#" + surface0

  // Sidebar/calendar/content sections inside larger panels.
  readonly property color panelContainerBackground: withAlpha(crust0, panelContainerAlpha)
  readonly property color panelContainerForeground: primaryForeground
  readonly property color panelContainerBorder: "#40" + mantle1

  // Repeated cards such as media cards, theme cards, and wallpaper cards.
  readonly property color panelCardBackground: withAlpha(base1, panelCardAlpha)
  readonly property color panelCardForeground: primaryForeground
  readonly property color panelCardBorder: "#9e" + surface1

  // Buttons, tabs, pills, and calendar day cells.
  readonly property color panelButtonBackground: withAlpha(surface0, panelButtonAlpha)
  readonly property color panelButtonBackgroundSubtle: "#" + surface1
  readonly property color panelButtonBackgroundHover: "#ee" + surface1
  readonly property color panelButtonBackgroundActive: accentBackground
  readonly property color panelButtonForeground: primaryForeground
  readonly property color panelButtonBorder: panelBorder
  readonly property color panelButtonBorderActive: "#b8" + accent0

  // Workspace pills.
  readonly property color workspaceInactiveBackground: "#c2" + surface0
  readonly property color workspaceOccupiedBackground: "#e6" + surface1

  // Text inputs and search fields.
  readonly property color panelInputBackground: withAlpha(surface0, panelInputAlpha)
  readonly property color panelInputForeground: primaryForeground
  readonly property color panelInputBorder: panelBorder
  readonly property color panelInputBorderActive: panelButtonBorderActive

  // Status colors.
  readonly property color infoForeground: "#" + info0
  readonly property color successForeground: "#" + success0
  readonly property color warningForeground: "#" + warning0
  readonly property color dangerForeground: "#" + danger0
  readonly property color infoBackground: "#33" + info0
  readonly property color successBackground: "#33" + success0
  readonly property color warningBackground: "#33" + warning0
  readonly property color dangerBackground: "#33" + danger0

  // Overlays.
  readonly property color scrim: withAlpha(crust1, scrimAlpha)
  readonly property color scrimSoft: withAlpha(crust1, scrimSoftAlpha)
  readonly property color imageOverlay: withAlpha(crust1, imageOverlayAlpha)
}
