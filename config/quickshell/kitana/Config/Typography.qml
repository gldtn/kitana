// Kitana managed Quickshell typography tokens

pragma Singleton

import QtQuick
import Quickshell

PersistentProperties {
    reloadableId: "kitanaQuickshellTypography"

    readonly property var fontFamilies: [
        "JetBrainsMono Nerd Font Propo",
        "Noto Sans",
        "Noto Sans Display",
        "Noto Sans Mono",
        "Noto Serif",
        "Ioskeley Mono"
    ]

    property string fontFamily: "JetBrainsMono Nerd Font Propo"
    readonly property string iconFontFamily: "JetBrainsMono Nerd Font Propo"
}
