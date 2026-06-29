// Kitana managed Quickshell dashboard tab

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Shapes
import "../.."
import "../Components"
import "../../Components/Controls" as Controls
import "../../custom" as Custom
import "../../Services" as Services

Item {
    id: tabRoot

    Custom.Settings {
        id: settings
    }

    property var dashboard: null
    readonly property var panel: dashboard
    readonly property bool mediaActive: panel !== null && panel.panelVisible && panel.activeTab === "media"
    readonly property bool audioOverlayOpen: panel !== null && panel.mediaAudioOverlayOpen
    readonly property string albumArtSource: Services.MediaService.artSource()
    readonly property real progressInset: 9

    Layout.fillWidth: true
    Layout.fillHeight: true

    function closeAudioOverlay(): void {
        if (panel !== null)
            panel.mediaAudioOverlayOpen = false;
    }

    function toggleAudioOverlay(): void {
        if (panel === null)
            return;

        Services.SystemStatus.refresh();
        panel.mediaAudioOverlayOpen = !panel.mediaAudioOverlayOpen;
    }

    // Keep MPRIS position bindings fresh only while this tab is visible.
    Timer {
        interval: 1000
        running: tabRoot.mediaActive && Services.MediaService.playing
        repeat: true
        triggeredOnStart: true
        onTriggered: Services.MediaService.refreshPosition()
    }

    // Material-style media playback card
    Rectangle {
        id: mediaCard

        anchors.fill: parent
        radius: 24
        color: Colors.bgSecondary
        border.color: Colors.borderFaint
        border.width: 0.8
        clip: true

        // Masked accent pools preserve the edge-circle look without leaking past rounded corners.
        Item {
            id: mediaAccentSource

            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                width: 260
                height: 260
                x: parent.width - width * 0.62
                y: -height * 0.55
                radius: width / 2
                color: Colors.alpha(Colors.bgAccent, Services.MediaService.playing ? 0.28 : 0.14)
            }

            Rectangle {
                width: 220
                height: 220
                x: -width * 0.45
                y: parent.height - height * 0.48
                radius: width / 2
                color: Colors.alpha(Colors.fgAccent, 0.12)
            }
        }

        Rectangle {
            id: mediaAccentMask

            anchors.fill: parent
            radius: mediaCard.radius
            visible: false
            layer.enabled: true
        }

        MultiEffect {
            anchors.fill: mediaAccentSource
            source: mediaAccentSource
            maskEnabled: true
            maskSource: mediaAccentMask
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Album hero and currently playing metadata
            Rectangle {
                id: mediaHero

                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(174, Math.min(214, mediaCard.height * 0.48))
                radius: 28
                color: Colors.alpha(Colors.bgTertiary, 0.96)
                border.width: 0
                clip: true

                Item {
                    id: heroAccentSource

                    anchors.fill: parent
                    visible: false
                    layer.enabled: true

                    Rectangle {
                        width: 190
                        height: 190
                        x: parent.width - width * 0.58
                        y: parent.height - height * 0.72
                        radius: width / 2
                        color: Colors.alpha(Colors.bgAccent, 0.22)
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 16

                    // Rounded album artwork or icon fallback
                    Rectangle {
                        id: albumCover

                        Layout.preferredWidth: Math.min(214, Math.max(144, mediaHero.width * 0.34))
                        Layout.fillHeight: true
                        radius: 24
                        color: Colors.bgPrimary
                        border.width: 0
                        clip: true

                        Image {
                            id: albumArt

                            anchors.fill: parent
                            anchors.margins: 1
                            source: tabRoot.albumArtSource
                            sourceSize.width: width
                            sourceSize.height: height
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: false
                        }

                        Rectangle {
                            id: albumArtMask

                            anchors.fill: parent
                            anchors.margins: 1
                            radius: Math.max(0, albumCover.radius - 1)
                            visible: false
                            layer.enabled: true
                        }

                        MultiEffect {
                            anchors.fill: albumArt
                            source: albumArt
                            visible: tabRoot.albumArtSource.length > 0 && albumArt.status === Image.Ready
                            maskEnabled: true
                            maskSource: albumArtMask
                        }

                        Controls.Icon {
                            anchors.centerIn: parent
                            visible: !(tabRoot.albumArtSource.length > 0 && albumArt.status === Image.Ready)
                            name: "media.default"
                            tone: "accent"
                            size: Math.round(Math.min(parent.width, parent.height) * 0.44)
                        }
                        // Album cover border
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 0
                            radius: albumCover.radius
                            color: "transparent"
                            border.color: Colors.borderHeavy
                            border.width: 1.3
                        }
                    }

                    // Playback identity, title, and artist stack
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.preferredWidth: Math.min(190, Math.max(116, playerLabel.implicitWidth + 26))
                                Layout.preferredHeight: 32
                                radius: 16
                                color: Colors.alpha(Colors.bgPrimary, 0.54)
                                border.color: Colors.alpha(Colors.borderLight, 0.56)
                                border.width: 1

                                Text {
                                    id: playerLabel

                                    anchors.centerIn: parent
                                    width: parent.width - 20
                                    text: Services.MediaService.playerName
                                    color: Colors.fgAccent
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                    font.family: Typography.fontFamily
                                    font.pixelSize: settings.textPixelSize
                                    font.weight: Font.DemiBold
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                Layout.preferredWidth: 88
                                Layout.preferredHeight: 32
                                radius: 16
                                color: Services.MediaService.playing ? Colors.subtleAccent : Colors.alpha(Colors.bgPrimary, 0.46)
                                border.color: Services.MediaService.playing ? Colors.borderAccent : Colors.borderFaint
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: Services.MediaService.status
                                    color: Services.MediaService.playing ? Colors.fgPrimary : Colors.fgSecondary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: settings.textPixelSize
                                    font.weight: Font.DemiBold
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        Text {
                            Layout.fillWidth: true
                            text: Services.MediaService.title
                            color: Colors.fgPrimary
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.Wrap
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.max(20, Math.min(24, mediaHero.height / 7.2))
                            font.weight: Font.Black
                        }

                        Text {
                            Layout.fillWidth: true
                            text: Services.MediaService.artist.length > 0 ? Services.MediaService.artist : "Unknown Artist"
                            color: Colors.fgSecondary
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize + 2
                            font.weight: Font.DemiBold
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: Services.MediaService.album.length > 0
                            text: Services.MediaService.album
                            color: Colors.fgTertiary
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize
                        }
                    }
                }

                // mediaHero border
                Rectangle {
                    id: mediaHeroBorder

                    anchors.fill: parent
                    anchors.margins: 0
                    radius: mediaHero.radius
                    color: "transparent"
                    border.color: Colors.alpha(Colors.borderLight, 0.72)
                    border.width: 0.8
                }
            }

            // Seekable track progress with elapsed and total time
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: tabRoot.progressInset
                    Layout.rightMargin: tabRoot.progressInset
                    spacing: 8

                    Text {
                        text: Services.MediaService.positionLabel
                        color: Colors.fgSecondary
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.DemiBold
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: Services.MediaService.lengthLabel
                        color: Colors.fgSecondary
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.DemiBold
                    }
                }

                Item {
                    id: progressTrack

                    Layout.fillWidth: true
                    Layout.preferredHeight: 32

                    readonly property real strokeInset: tabRoot.progressInset
                    readonly property real strokeEnd: Math.max(strokeInset, width - strokeInset)
                    readonly property real strokeSpan: Math.max(1, strokeEnd - strokeInset)
                    readonly property real progressX: strokeInset + strokeSpan * (Services.MediaService.hasProgress ? Services.MediaService.progress : 0)
                    readonly property real waveAmplitude: 3.2
                    readonly property real waveHalfStep: Math.max(30, Math.min(44, strokeSpan / 9))

                    function ratioFromX(pointerX: real): real {
                        return (pointerX - strokeInset) / strokeSpan;
                    }

                    function wavePath(targetX: real): string {
                        const centerY = height / 2;
                        const endX = Math.max(strokeInset, Math.min(strokeEnd, targetX));
                        if (endX <= strokeInset + 1)
                            return "";

                        let path = "M " + strokeInset + " " + centerY;
                        let x = strokeInset;
                        let waveSign = -1;

                        while (x < endX - 0.5) {
                            const nextX = Math.min(endX, x + waveHalfStep);
                            const span = nextX - x;
                            const controlY = centerY + waveSign * waveAmplitude * 1.22;
                            path += " C " + (x + span / 3) + " " + controlY + " " + (nextX - span / 3) + " " + controlY + " " + nextX + " " + centerY;
                            x = nextX;
                            waveSign *= -1;
                        }

                        return path;
                    }

                    Rectangle {
                        x: Services.MediaService.hasProgress && progressTrack.progressX > progressTrack.strokeInset + 1 ? Math.min(progressTrack.strokeEnd, progressTrack.progressX + 10) : progressTrack.strokeInset
                        width: Math.max(0, progressTrack.strokeEnd - x)
                        height: 5
                        anchors.verticalCenter: parent.verticalCenter
                        radius: height / 2
                        color: Colors.alpha(Colors.fgSecondary, 0.34)
                    }

                    Shape {
                        anchors.fill: parent
                        visible: Services.MediaService.hasProgress && progressTrack.progressX > progressTrack.strokeInset + 1
                        preferredRendererType: Shape.CurveRenderer

                        ShapePath {
                            fillColor: "transparent"
                            strokeColor: Colors.lighten(Colors.bgAccent, 0.30)
                            strokeWidth: 7
                            capStyle: ShapePath.RoundCap
                            joinStyle: ShapePath.RoundJoin

                            PathSvg {
                                path: progressTrack.wavePath(progressTrack.progressX)
                            }
                        }
                    }

                    Rectangle {
                        width: 7
                        height: 7
                        x: progressTrack.strokeEnd - width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        radius: width / 2
                        color: Colors.lighten(Colors.bgAccent, 0.30)
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: Services.MediaService.canSeek && Services.MediaService.hasProgress
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onPressed: mouse => Services.MediaService.setPosition(progressTrack.ratioFromX(mouse.x))
                        onPositionChanged: mouse => {
                            if (pressed)
                                Services.MediaService.setPosition(progressTrack.ratioFromX(mouse.x));
                        }
                    }
                }
            }

            // Playback controls and optional queue mode chips
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                Layout.topMargin: -4
                Layout.bottomMargin: 8
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 96
                    Layout.preferredHeight: 42
                    visible: Services.MediaService.shuffleSupported
                    radius: 21
                    color: Services.MediaService.shuffle ? Colors.subtleAccent : Colors.alpha(Colors.bgPrimary, 0.58)
                    border.color: Services.MediaService.shuffle ? Colors.borderAccent : Colors.borderFaint
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Shuffle"
                        color: Services.MediaService.shuffle ? Colors.fgPrimary : Colors.fgSecondary
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.MediaService.toggleShuffle()
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                MediaButton {
                    iconName: "media.previous"
                    enabled: Services.MediaService.canPrevious
                    onClicked: Services.MediaService.previous()
                }

                MediaButton {
                    iconName: Services.MediaService.playing ? "media.pause" : "media.play"
                    prominent: true
                    enabled: Services.MediaService.canTogglePlaying
                    onClicked: Services.MediaService.playPause()
                }

                MediaButton {
                    iconName: "media.next"
                    enabled: Services.MediaService.canNext
                    onClicked: Services.MediaService.next()
                }

                MediaButton {
                    iconName: "media.stop"
                    enabled: Services.MediaService.canStop
                    onClicked: Services.MediaService.stop()
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 112
                    Layout.preferredHeight: 42
                    visible: Services.MediaService.loopSupported
                    radius: 21
                    color: Services.MediaService.looping ? Colors.subtleAccent : Colors.alpha(Colors.bgPrimary, 0.58)
                    border.color: Services.MediaService.looping ? Colors.borderAccent : Colors.borderFaint
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: Services.MediaService.loopLabel
                        color: Services.MediaService.looping ? Colors.fgPrimary : Colors.fgSecondary
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.MediaService.cycleLoop()
                    }
                }
            }

            // Material expressive audio footer
            Rectangle {
                id: audioFooter

                Layout.fillWidth: true
                Layout.preferredHeight: 44
                Layout.bottomMargin: 22
                radius: 20
                color: mediaHero.color
                border.color: mediaHeroBorder.border.color
                border.width: mediaHeroBorder.border.width
                readonly property real innerItemHeight: 28

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    anchors.topMargin: 5
                    anchors.bottomMargin: 5
                    spacing: 8

                    // Output picker button
                    Rectangle {
                        Layout.preferredWidth: audioFooter.innerItemHeight
                        Layout.preferredHeight: audioFooter.innerItemHeight
                        Layout.alignment: Qt.AlignVCenter
                        radius: 15
                        color: outputPickerMouse.containsMouse || tabRoot.audioOverlayOpen ? Colors.alpha(Colors.bgAccent, 0.28) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: Icons.glyph("ui.more.horizontal")
                            color: tabRoot.audioOverlayOpen ? Colors.bgAccent : (Colors.dark ? Colors.bgPrimary : Colors.fgPrimary)
                            font.family: Typography.iconFontFamily
                            font.pixelSize: settings.iconPixelSize + 4
                        }

                        MouseArea {
                            id: outputPickerMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: tabRoot.toggleAudioOverlay()
                        }
                    }

                    // Smooth volume drag surface
                    Rectangle {
                        id: volumeSurface

                        Layout.fillWidth: true
                        Layout.preferredHeight: audioFooter.innerItemHeight
                        Layout.alignment: Qt.AlignVCenter
                        radius: 8
                        color: "transparent"

                        readonly property real fillRatio: Math.max(0, Math.min(1, Services.SystemStatus.audioVolume / 100))
                        readonly property real fillWidth: width * fillRatio
                        readonly property bool fillAtMax: fillRatio >= 0.995
                        readonly property real splitterWidth: 5
                        readonly property real splitterGap: 8
                        readonly property bool splitterVisible: fillRatio > 0.04 && !fillAtMax
                        readonly property real splitterX: Math.max(radius, Math.min(width - radius - splitterWidth, fillWidth - splitterWidth / 2))
                        readonly property real activeWidth: fillAtMax ? width : (splitterVisible ? Math.max(0, splitterX - splitterGap) : fillWidth)
                        readonly property real inactiveX: fillAtMax ? width : (splitterVisible ? Math.min(width, splitterX + splitterWidth + splitterGap) : fillWidth)
                        readonly property real inactiveWidth: Math.max(0, width - inactiveX)

                        function ratioFromX(pointerX: real): real {
                            return Math.max(0, Math.min(1, pointerX / Math.max(1, width)));
                        }

                        Item {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: volumeSurface.activeWidth
                            clip: !volumeSurface.fillAtMax
                            visible: volumeSurface.activeWidth > 0.5

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: volumeSurface.activeWidth + (volumeSurface.fillAtMax ? 0 : volumeSurface.radius)
                                radius: volumeSurface.radius
                                color: Services.SystemStatus.audioMuted ? Colors.alpha(Colors.fgSecondary, 0.28) : Colors.bgAccent
                            }
                        }

                        Item {
                            x: volumeSurface.inactiveX
                            width: volumeSurface.inactiveWidth
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            clip: true
                            visible: volumeSurface.inactiveWidth > 0.5

                            Rectangle {
                                x: volumeSurface.splitterVisible ? -volumeSurface.radius : 0
                                width: parent.width + (volumeSurface.splitterVisible ? volumeSurface.radius : 0)
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                radius: volumeSurface.radius
                                color: Colors.alpha(Colors.fgSecondary, Colors.dark ? 0.28 : 0.38)
                            }

                            Rectangle {
                                width: 5
                                height: 5
                                x: parent.width - width - 12
                                anchors.verticalCenter: parent.verticalCenter
                                visible: parent.width > 34
                                radius: width / 2
                                color: Colors.alpha(Colors.bgOnPrimary, 0.82)
                            }
                        }

                        Rectangle {
                            width: volumeSurface.splitterWidth
                            height: parent.height + 8
                            x: volumeSurface.splitterX
                            y: -4
                            visible: volumeSurface.splitterVisible
                            radius: width / 2
                            color: Services.SystemStatus.audioMuted ? Colors.alpha(Colors.fgSecondary, 0.48) : Colors.bgAccent
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            text: Services.SystemStatus.audioMuted ? "Muted" : Services.SystemStatus.audioVolume + "%"
                            color: volumeSurface.fillRatio > 0.22 && !Services.SystemStatus.audioMuted ? Colors.fgOnPrimary : (Colors.dark ? Colors.bgPrimary : Colors.fgPrimary)
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize + 1
                            font.weight: Font.Black
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onPressed: mouse => Services.SystemStatus.setAudioVolume(volumeSurface.ratioFromX(mouse.x) * 100)
                            onPositionChanged: mouse => {
                                if (pressed)
                                    Services.SystemStatus.setAudioVolume(volumeSurface.ratioFromX(mouse.x) * 100);
                            }
                        }
                    }

                    // Mute toggle button
                    Rectangle {
                        Layout.preferredWidth: audioFooter.innerItemHeight
                        Layout.preferredHeight: audioFooter.innerItemHeight
                        Layout.alignment: Qt.AlignVCenter
                        radius: 15
                        color: Services.SystemStatus.audioMuted ? Colors.alpha(Colors.fgSecondary, 0.28) : Colors.bgAccent

                        Controls.Icon {
                            anchors.centerIn: parent
                            name: Services.SystemStatus.audioIconName
                            tone: Services.SystemStatus.audioMuted ? "primary" : "onAccent"
                            size: settings.iconPixelSize - 1
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Services.SystemStatus.toggleAudioMute()
                        }
                    }
                }
            }
        }

        // Audio overlay close catcher
        MouseArea {
            anchors.fill: parent
            enabled: tabRoot.audioOverlayOpen
            visible: tabRoot.audioOverlayOpen
            onClicked: tabRoot.closeAudioOverlay()
        }

        // Audio output overlay card
        Rectangle {
            id: audioOverlay

            width: Math.min(360, parent.width - 36)
            height: Math.min(260, parent.height - 36)
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 18
            visible: tabRoot.audioOverlayOpen
            radius: 24
            color: Colors.bgPrimary
            border.color: Colors.borderAccent
            border.width: 1

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

                    Controls.CloseButton {
                        buttonSize: 30
                        onClicked: tabRoot.closeAudioOverlay()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: 18
                    color: Colors.subtleAccent
                    border.color: Colors.borderFaint
                    border.width: 1

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        text: Services.SystemStatus.audioSink
                        color: Colors.fgPrimary
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.DemiBold
                    }
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
