// Kitana managed Quickshell dashboard tab

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import "../.."
import "../Components"
import "../../Components/Controls" as Controls
import "../../custom" as Custom
import "../../Services" as Services

Item {
    id: tabRoot

    Custom.Settings { id: settings }

    property var dashboard: null
    readonly property var panel: dashboard

    Layout.fillWidth: true
    Layout.fillHeight: true

    // Media playback card
    Rectangle {
        id: mediaCard

        anchors.fill: parent
        radius: 18
        color: Colors.bgSecondary
        border.color: Colors.borderFaint
        border.width: 1
        clip: true

        // Background audio visualizer bars
        CavaBars {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            anchors.bottomMargin: 92
            height: 82
            dashboard: tabRoot.panel
        }

        // Main media content layout
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 16

            // Album art and playback metadata row
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 18

                // Album art frame
                Rectangle {
                    id: albumCover

                    Layout.preferredWidth: 180
                    Layout.preferredHeight: 132
                    Layout.alignment: Qt.AlignTop
                    radius: 14
                    color: Colors.bgPrimary
                    border.color: Colors.bgPrimary
                    border.width: 1
                    clip: true

                    // Raw album art image
                    Image {
                        id: albumArt

                        anchors.fill: parent
                        source: Services.MediaService.artSource()
                        fillMode: Image.Tile
                        asynchronous: true
                        visible: false
                    }

                    // Rounded album art mask
                    Rectangle {
                        id: albumArtMask

                        anchors.fill: parent
                        radius: albumCover.radius
                        visible: false
                        layer.enabled: true
                    }

                    // Masked album art effect
                    MultiEffect {
                        anchors.fill: albumArt
                        source: albumArt
                        visible: albumArt.source.toString().length > 0 && albumArt.status === Image.Ready
                        maskEnabled: true
                        maskSource: albumArtMask
                    }

                    // Fallback media icon
                    Controls.Icon {
                        anchors.centerIn: parent
                        visible: Services.MediaService.artSource().length === 0
                        name: "media.default"
                        tone: "accent"
                        size: 64
                    }

                    // Album art dark overlay
                    Rectangle {
                        anchors.fill: parent
                        radius: albumCover.radius
                        color: "#18000000"
                    }

                    // Album art highlight overlay
                    Rectangle {
                        anchors.fill: parent
                        radius: albumCover.radius
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#38ffffff" }
                            GradientStop { position: 0.38; color: "#00ffffff" }
                            GradientStop { position: 1.0; color: "#00000000" }
                        }
                    }

                    // Album art bottom fade
                    Rectangle {
                        anchors.fill: parent
                        radius: albumCover.radius
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#00000000" }
                            GradientStop { position: 0.55; color: "#00000000" }
                            GradientStop { position: 1.0; color: "#66000000" }
                        }
                    }

                    // Album art inner border
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -1
                        radius: Math.max(0, albumCover.radius - 1)
                        color: "transparent"
                        border.color: albumCover.border.color
                        border.width: 6
                    }
                }

                // Playback metadata and controls
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    // Player name, status, and audio menu row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            Layout.fillWidth: true
                            text: Services.MediaService.playerName
                            color: Colors.fgAccent
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize
                            font.weight: Font.DemiBold
                        }

                        Rectangle {
                            Layout.preferredWidth: 84
                            Layout.preferredHeight: 30
                            radius: 10
                            color: tabRoot.panel.mediaPlaying ? Colors.subtlePrimary : Colors.bgTertiary
                            border.color: Colors.borderFaint
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: Services.MediaService.status
                                color: tabRoot.panel.mediaPlaying ? Colors.fgPrimary : Colors.fgSecondary
                                font.family: Typography.fontFamily
                                font.pixelSize: settings.textPixelSize
                                font.weight: Font.DemiBold
                            }
                        }

                        MediaButton {
                            iconName: Services.SystemStatus.audioIconName
                            onClicked: {
                                Services.SystemStatus.refresh();
                                tabRoot.panel.mediaAudioOverlayOpen = !tabRoot.panel.mediaAudioOverlayOpen;
                            }
                        }
                    }

                    // Marquee title clip area
                    Item {
                        id: mediaTitleClip

                        Layout.fillWidth: true
                        Layout.preferredHeight: mediaTitleText.implicitHeight
                        clip: true

                        // Track title text
                        Text {
                            id: mediaTitleText

                            x: 0
                            text: Services.MediaService.title
                            color: Colors.fgPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: 28
                            font.weight: Font.Bold

                            onTextChanged: x = 0
                        }

                        // Long title marquee animation
                        SequentialAnimation {
                            id: mediaTitleMarquee

                            loops: Animation.Infinite
                            running: tabRoot.panel.visible && tabRoot.panel.activeTab === "media" && mediaTitleText.implicitWidth > mediaTitleClip.width
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
                        color: Colors.fgSecondary
                        elide: Text.ElideRight
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize + 1
                    }

                    // Push transport controls to the bottom
                    Item { Layout.fillHeight: true }

                    // Playback transport controls
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        MediaButton { iconName: "media.previous"; onClicked: Services.MediaService.previous() }
                        MediaButton { iconName: tabRoot.panel.mediaPlaying ? "media.pause" : "media.play"; prominent: true; onClicked: Services.MediaService.playPause() }
                        MediaButton { iconName: "media.stop"; onClicked: Services.MediaService.stop() }
                        MediaButton { iconName: "media.next"; onClicked: Services.MediaService.next() }
                        Item { Layout.fillWidth: true }
                        MediaButton { iconName: "media.refresh"; onClicked: tabRoot.panel.refreshMedia() }
                    }
                }
            }
        }

        // Audio overlay close catcher
        MouseArea {
            anchors.fill: parent
            visible: tabRoot.panel.mediaAudioOverlayOpen
            onClicked: tabRoot.panel.mediaAudioOverlayOpen = false
        }

        // Audio overlay scrim
        Rectangle {
            anchors.fill: parent
            visible: tabRoot.panel.mediaAudioOverlayOpen
            color: Colors.scrimSecondary
        }

        // Audio output overlay card
        Rectangle {
            id: audioOverlay

            width: Math.min(330, parent.width - 36)
            height: Math.min(300, parent.height - 36)
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 18
            visible: tabRoot.panel.mediaAudioOverlayOpen
            radius: 16
            color: Colors.bgPrimary
            border.color: Colors.borderAccent
            border.width: 2
            opacity: visible ? 1 : 0

            // Audio output controls and device list
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                // Audio overlay header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: "Audio Output"
                        color: Colors.fgPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: 15
                        font.weight: Font.Bold
                    }

                    MiniButton {
                        iconName: "ui.close"
                        widthOverride: 32
                        heightOverride: 30
                        onClicked: tabRoot.panel.mediaAudioOverlayOpen = false
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: Services.SystemStatus.audioSink
                    color: Colors.fgSecondary
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

                // Scrollable audio output devices
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: width
                    contentHeight: mediaDeviceList.implicitHeight

                    // Audio output device rows
                    ColumnLayout {
                        id: mediaDeviceList

                        width: parent.width
                        spacing: 8

                        // One row per audio sink
                        Repeater {
                            model: Services.SystemStatus.audioSinks

                            MediaDeviceRow {
                                required property var modelData

                                name: modelData.name
                                iconName: modelData.iconName || "audio.output"
                                subtitle: modelData.subtitle || "Output device"
                                active: Services.SystemStatus.audioSink === modelData.name
                                onClicked: Services.SystemStatus.setAudioSink(modelData.id)
                            }
                        }

                        // Empty audio device message
                        Text {
                            Layout.fillWidth: true
                            visible: Services.SystemStatus.audioSinks.length === 0
                            text: "No output devices found"
                            color: Colors.fgSecondary
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
