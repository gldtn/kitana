// Kitana managed Quickshell system pane

import QtQuick
import "../.."
import "../Components"
import "../../custom" as Custom
import "../../Services" as Services

Flickable {
    id: root

    Custom.Settings { id: settings }

    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    clip: true
    contentWidth: width
    contentHeight: audioList.implicitHeight

    Column {
        id: audioList

        width: parent.width
        spacing: 10

        Text {
            width: parent.width
            text: "Microphone"
            color: Colors.foreground
            font.family: Typography.fontFamily
            font.pixelSize: 14
            font.weight: Font.Bold
        }

        DetailRow {
            iconName: Services.SystemStatus.micIconName
            title: Services.SystemStatus.micAvailable ? Services.SystemStatus.micSource : "No microphone"
            subtitle: Services.SystemStatus.micLabel
            active: Services.SystemStatus.micAvailable && !Services.SystemStatus.micMuted
            clickable: Services.SystemStatus.micAvailable
            onClicked: Services.SystemStatus.toggleMicMute()
        }

        DetailList {
            width: parent.width
            title: "Audio Outputs"
            emptyText: "No output devices found"
            modelData: Services.SystemStatus.audioSinks
            delegateComponent: audioSinkRow
        }
    }

    Component {
        id: audioSinkRow

        DetailRow {
            required property var modelData
            iconName: modelData.iconName || "audio.output"
            title: modelData.name
            subtitle: Services.SystemStatus.audioSink === modelData.name ? "Current output" : (modelData.subtitle || "Output device")
            active: Services.SystemStatus.audioSink === modelData.name
            onClicked: Services.SystemStatus.setAudioSink(modelData.id)
        }
    }
}
