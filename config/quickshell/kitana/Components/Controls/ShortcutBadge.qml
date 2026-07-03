// Kitana managed Quickshell control

import "../.."

// Keyboard shortcut badge wrapper over the shared Badge control.
Badge {
    id: root

    property int textPixelSize: root.defaultFontPixelSize()
    property string tone: "subtle"

    size: "xs"
    colorVariant: "subtle"
    badgeHeight: 18
    horizontalPadding: 5
    fontPixelSize: textPixelSize
    cornerRadius: 6
    backgroundColor: Colors.scrimSecondary
    foregroundColor: Icons.toneColor(root.tone)
    borderColor: Colors.borderLight
    borderWidth: 0.8
}
