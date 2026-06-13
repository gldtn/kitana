// Kitana managed Quickshell service

pragma Singleton

import QtQuick
import Quickshell
import ".."

Singleton {
    id: root

    PersistentProperties {
        id: state
        reloadableId: "kitanaCaffeineState"

        property bool enabled: false
    }

    property alias enabled: state.enabled
    readonly property string iconName: Icons.caffeineName(enabled)
    readonly property string subtitle: enabled ? "On" : "Off"

    function toggle(): void {
        enabled = !enabled;
    }
}
