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

    readonly property var iconFontFamilies: [
        "JetBrainsMono Nerd Font Propo",
        "JetBrainsMono Nerd Font",
        "JetBrainsMono Nerd Font Mono",
        "JetBrainsMonoNL Nerd Font Propo",
        "CaskaydiaMono Nerd Font Propo",
        "CaskaydiaMono Nerd Font",
        "IoskeleyMonoTerm Nerd Font",
        "Material Symbols Rounded",
        "Material Symbols Outlined",
        "Material Symbols Sharp"
    ]

    readonly property var iconFillValues: [0, 1]
    readonly property var iconWeightValues: [100, 200, 300, 400, 500, 600, 700]
    readonly property var iconGradeValues: [-25, 0, 200]
    readonly property var iconOpticalSizeValues: [20, 24, 40, 48]

    property string fontFamily: "JetBrainsMono Nerd Font Propo"
    property string iconFontFamily: "JetBrainsMono Nerd Font Propo"
    property int iconFill: 0
    property int iconWeight: 400
    property int iconGrade: 0
    property int iconOpticalSize: 24

    readonly property bool materialIcons: iconFontFamily.indexOf("Material Symbols") === 0
}
