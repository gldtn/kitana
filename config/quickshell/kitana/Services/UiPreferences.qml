// Kitana managed Quickshell service

pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    PersistentProperties {
        id: state
        reloadableId: "kitanaUiPreferences"

        property string layoutPillDisplayMode: "compact"
    }

    property alias layoutPillDisplayMode: state.layoutPillDisplayMode
    readonly property var layoutPillDisplayModes: ["icons", "compact", "full"]

    function setLayoutPillDisplayMode(mode: string): void {
        if (layoutPillDisplayModes.indexOf(mode) !== -1)
            layoutPillDisplayMode = mode;
    }
}
