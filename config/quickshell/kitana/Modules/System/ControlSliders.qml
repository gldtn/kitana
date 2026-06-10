// Kitana managed Quickshell system component

import QtQuick
import "../../Services" as Services

Column {
    id: root

    width: parent ? parent.width : 0
    spacing: 10

    SliderRow {
        icon: Services.SystemStatus.audioIcon
        value: Services.SystemStatus.audioVolume
        label: Services.SystemStatus.audioLabel
        iconClickable: true
        onIconClicked: Services.SystemStatus.toggleAudioMute()
        onMoved: value => Services.SystemStatus.setAudioVolume(value)
    }

    SliderRow {
        visible: Services.SystemStatus.micAvailable
        height: visible ? 28 : 0
        icon: Services.SystemStatus.micIcon
        value: Services.SystemStatus.micVolume
        label: Services.SystemStatus.micLabel
        iconClickable: true
        onIconClicked: Services.SystemStatus.toggleMicMute()
        onMoved: value => Services.SystemStatus.setMicVolume(value)
    }

    SliderRow {
        visible: Services.SystemStatus.brightnessAvailable
        height: visible ? 28 : 0
        icon: "󰃠"
        value: Services.SystemStatus.brightness
        label: Services.SystemStatus.brightness + "%"
        onMoved: value => Services.SystemStatus.setBrightness(value)
    }
}
