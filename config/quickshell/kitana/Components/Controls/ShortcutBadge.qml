// Kitana managed Quickshell control

// Keyboard shortcut badge wrapper over the shared Badge control.

Badge {
    id: root

    property int textPixelSize: root.defaultFontPixelSize()
    property string tone: "subtle"

    size: "xs"
    colorVariant: "subtle"
    hasBorder: true
    border.width: 0.8
    // icon: "input.keyboard"
}
