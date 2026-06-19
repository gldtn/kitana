// Kitana managed Quickshell control

import QtQuick
import "../.."

// Soft modal backdrop tint for Hyprland compositor-side blur.
Rectangle {
    color: Colors.alpha(Colors.bgPrimary, Colors.dark ? 0.18 : 0.24)
}
