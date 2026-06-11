// Kitana managed Quickshell colors

pragma Singleton

import QtQuick

QtObject {
  // Alpha reference:
  // 98% = fa
  // 96% = f5
  // 90% = e6
  // 86% = db
  // 80% = cc
  // 76% = c2
  // 70% = b3
  // 66% = a8
  // 60% = 99
  // 45% = 73

  function withAlpha(rgb: string, alpha: string): string {
    return "#" + alpha + rgb;
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
  readonly property string panelAlpha: "fa"
  readonly property string panelContainerAlpha: "73"
  readonly property string panelCardAlpha: "99"
  readonly property string panelButtonAlpha: "cc"
  readonly property string panelInputAlpha: "cc"
  readonly property string scrimAlpha: "85"
  readonly property string scrimSoftAlpha: "52"
  readonly property string imageOverlayAlpha: "99"

  // Semantic foreground and background roles.
  readonly property color accentForeground: "#" + accent0
  readonly property color primaryForeground: "#" + text0
  readonly property color secondaryForeground: "#" + text1
  readonly property color mutedForeground: "#" + subtext0
  readonly property color accentBackground: "#33" + accent0
  readonly property color primaryBackground: "#" + base0
  readonly property color secondaryBackground: "#" + mantle0
  readonly property color mutedBackground: "#" + crust0

  // Outer dashboard/system/wallpaper picker shell.
  readonly property color panelBackground: withAlpha(base0, panelAlpha)
  readonly property color panelForeground: primaryForeground
  readonly property color panelBorder: "#9e" + surface0

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
  readonly property color panelButtonBackgroundHover: "#ee" + surface1
  readonly property color panelButtonBackgroundActive: accentBackground
  readonly property color panelButtonForeground: primaryForeground
  readonly property color panelButtonBorder: panelBorder
  readonly property color panelButtonBorderActive: "#b8" + accent0

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

  // Temporary legacy aliases. Remove after all Kitana/custom QML uses component tokens.
  readonly property color background: "#" + base0
  readonly property color surface: panelCardBackground
  readonly property color surfaceAlt: "#" + surface1
  readonly property color surfaceHover: panelButtonBackgroundHover
  readonly property color surfaceHighlight: panelButtonBackgroundActive
  readonly property color panelBorderStrong: panelButtonBorderActive
  readonly property color workspaceInactive: "#c2" + surface0
  readonly property color workspaceOccupied: "#e6" + surface1
  readonly property color foreground: primaryForeground
  readonly property color muted: mutedForeground
  readonly property color accent: accentForeground
  readonly property color accentText: "#" + crust0
  readonly property color info: infoForeground
  readonly property color success: successForeground
  readonly property color warning: warningForeground
  readonly property color danger: dangerForeground
}
