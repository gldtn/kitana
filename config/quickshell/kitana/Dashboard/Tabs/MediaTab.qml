// Kitana managed Quickshell dashboard tab

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import "../.."
import "../Components"
import "../../Components/Controls" as Controls
import "../../custom" as Custom
import "../../Services" as Services

Item {
    Custom.Settings { id: settings }

    property var dashboard: null
    readonly property var root: dashboard

    Layout.fillWidth: true
    Layout.fillHeight: true

    Rectangle {
        id: mediaCard

        anchors.fill: parent
        radius: 18
        color: Colors.panelContainerBackground
        border.color: Colors.panelContainerBorder
        border.width: 1
        clip: true

        CavaBars {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            anchors.bottomMargin: 92
            height: 82
            dashboard: root
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 18

                Rectangle {
                    id: albumCover

                    Layout.preferredWidth: 180
                    Layout.preferredHeight: 132
                    Layout.alignment: Qt.AlignTop
                    radius: 14
                    color: Colors.background
                    border.color: Colors.background
                    border.width: 1
                    clip: true

                    Image {
                        id: albumArt

                        anchors.fill: parent
                        source: Services.MediaService.artSource()
                        fillMode: Image.Tile
                        asynchronous: true
                        visible: false
                    }

                    Rectangle {
                        id: albumArtMask

                        anchors.fill: parent
                        radius: albumCover.radius
                        visible: false
                        layer.enabled: true
                    }

                    MultiEffect {
                        anchors.fill: albumArt
                        source: albumArt
                        visible: albumArt.source.toString().length > 0 && albumArt.status === Image.Ready
                        maskEnabled: true
                        maskSource: albumArtMask
                    }

                    Controls.Icon {
                        anchors.centerIn: parent
                        visible: Services.MediaService.artSource().length === 0
                        icon: Icons.media
                        color: Colors.accent
                        size: 64
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: albumCover.radius
                        color: "#18000000"
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: albumCover.radius
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#38ffffff" }
                            GradientStop { position: 0.38; color: "#00ffffff" }
                            GradientStop { position: 1.0; color: "#00000000" }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: albumCover.radius
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#00000000" }
                            GradientStop { position: 0.55; color: "#00000000" }
                            GradientStop { position: 1.0; color: "#66000000" }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -1
                        radius: Math.max(0, albumCover.radius - 1)
                        color: "transparent"
                        border.color: albumCover.border.color
                        border.width: 6
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            Layout.fillWidth: true
                            text: Services.MediaService.playerName
                            color: Colors.accent
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize
                            font.weight: Font.DemiBold
                        }

                        Rectangle {
                            Layout.preferredWidth: 84
                            Layout.preferredHeight: 30
                            radius: 10
                            color: root.mediaPlaying ? Colors.surfaceHighlight : Colors.surface
                            border.color: Colors.panelBorder
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: Services.MediaService.status
                                color: root.mediaPlaying ? Colors.foreground : Colors.muted
                                font.family: Typography.fontFamily
                                font.pixelSize: settings.textPixelSize
                                font.weight: Font.DemiBold
                            }
                        }

                        MediaButton {
                            text: Services.SystemStatus.audioIcon
                            onClicked: {
                                Services.SystemStatus.refresh();
                                root.mediaAudioOverlayOpen = !root.mediaAudioOverlayOpen;
                            }
                        }
                    }

                    Item {
                        id: mediaTitleClip

                        Layout.fillWidth: true
                        Layout.preferredHeight: mediaTitleText.implicitHeight
                        clip: true

                        Text {
                            id: mediaTitleText

                            x: 0
                            text: Services.MediaService.title
                            color: Colors.foreground
                            font.family: Typography.fontFamily
                            font.pixelSize: 28
                            font.weight: Font.Bold

                            onTextChanged: x = 0
                        }

                        SequentialAnimation {
                            id: mediaTitleMarquee

                            loops: Animation.Infinite
                            running: root.visible && root.activeTab === "media" && mediaTitleText.implicitWidth > mediaTitleClip.width
                            onRunningChanged: if (!running) mediaTitleText.x = 0

                            PauseAnimation { duration: 900 }
                            NumberAnimation {
                                target: mediaTitleText
                                property: "x"
                                from: 0
                                to: Math.min(0, mediaTitleClip.width - mediaTitleText.implicitWidth - 24)
                                duration: Math.max(3500, (mediaTitleText.implicitWidth - mediaTitleClip.width) * 28)
                                easing.type: Easing.InOutQuad
                            }
                            PauseAnimation { duration: 1200 }
                            NumberAnimation {
                                target: mediaTitleText
                                property: "x"
                                to: 0
                                duration: 600
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: Services.MediaService.artist + (Services.MediaService.album ? "  -  " + Services.MediaService.album : "")
                        color: Colors.muted
                        elide: Text.ElideRight
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize + 1
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        MediaButton { text: Icons.previous; onClicked: Services.MediaService.previous() }
                        MediaButton { text: root.mediaPlaying ? Icons.pause : Icons.play; prominent: true; onClicked: Services.MediaService.playPause() }
                        MediaButton { text: Icons.stop; onClicked: Services.MediaService.stop() }
                        MediaButton { text: Icons.next; onClicked: Services.MediaService.next() }
                        Item { Layout.fillWidth: true }
                        MediaButton { text: Icons.refresh; onClicked: root.refreshMedia() }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            visible: root.mediaAudioOverlayOpen
            onClicked: root.mediaAudioOverlayOpen = false
        }

        Rectangle {
            anchors.fill: parent
            visible: root.mediaAudioOverlayOpen
            color: Colors.scrimSoft
        }

        Rectangle {
            id: audioOverlay

            width: Math.min(330, parent.width - 36)
            height: Math.min(300, parent.height - 36)
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 18
            visible: root.mediaAudioOverlayOpen
            radius: 16
            color: Colors.background
            border.color: Colors.panelBorderStrong
            border.width: 2
            opacity: visible ? 1 : 0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: "Audio Output"
                        color: Colors.foreground
                        font.family: Typography.fontFamily
                        font.pixelSize: 15
                        font.weight: Font.Bold
                    }

                    MiniButton {
                        text: Icons.close
                        iconText: true
                        widthOverride: 32
                        heightOverride: 30
                        onClicked: root.mediaAudioOverlayOpen = false
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: Services.SystemStatus.audioSink
                    color: Colors.muted
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize
                }

                VolumeSlider {
                    Layout.fillWidth: true
                    value: Services.SystemStatus.audioVolume
                }

                MiniButton {
                    Layout.fillWidth: true
                    text: Services.SystemStatus.audioMuted ? "Unmute" : "Mute"
                    heightOverride: 34
                    onClicked: Services.SystemStatus.toggleAudioMute()
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: width
                    contentHeight: mediaDeviceList.implicitHeight

                    ColumnLayout {
                        id: mediaDeviceList

                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: Services.SystemStatus.audioSinks

                            MediaDeviceRow {
                                required property var modelData

                                name: modelData.name
                                icon: modelData.icon || Icons.audioOutput
                                subtitle: modelData.subtitle || "Output device"
                                active: Services.SystemStatus.audioSink === modelData.name
                                onClicked: Services.SystemStatus.setAudioSink(modelData.id)
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: Services.SystemStatus.audioSinks.length === 0
                            text: "No output devices found"
                            color: Colors.muted
                            horizontalAlignment: Text.AlignHCenter
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize
                        }
                    }
                }
            }
        }
    }
}
