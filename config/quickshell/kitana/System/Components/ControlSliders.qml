// Kitana managed Quickshell system component

import QtQuick
import "../../Services" as Services

Column {
    id: root

    width: parent ? parent.width : 0
    spacing: 10

    SliderRow {
        iconName: Services.SystemStatus.audioIconName
        value: Services.SystemStatus.audioVolume
        label: Services.SystemStatus.audioLabel
        iconClickable: true
        onIconClicked: Services.SystemStatus.toggleAudioMute()
        onMoved: value => Services.SystemStatus.setAudioVolume(value)
    }

    SliderRow {
        visible: Services.SystemStatus.micAvailable
        height: visible ? 28 : 0
        iconName: Services.SystemStatus.micIconName
        value: Services.SystemStatus.micVolume
        label: Services.SystemStatus.micLabel
        iconClickable: true
        onIconClicked: Services.SystemStatus.toggleMicMute()
        onMoved: value => Services.SystemStatus.setMicVolume(value)
    }

    SliderRow {
        visible: Services.SystemStatus.brightnessAvailable
        height: visible ? 28 : 0
        iconName: "brightness"
        value: Services.SystemStatus.brightness
        label: Services.SystemStatus.brightness + "%"
        onMoved: value => Services.SystemStatus.setBrightness(value)
    }
}
