// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../Components/Controls" as Controls
import "../../Services" as Services

Item {
    id: root

    property int value: 0

    Layout.preferredHeight: 28

    // Shared volume slider control.
    Controls.ValueSlider {
        id: volumeSlider

        anchors.fill: parent
        value: root.value
        enabled: Services.SystemStatus.audioAvailable
        fillColor: Services.SystemStatus.audioMuted ? Colors.borderFaint : Colors.fgAccent
        handleColor: fillColor
        onMoved: Services.SystemStatus.setAudioVolume(volumeSlider.value)
    }
}
