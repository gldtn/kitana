// Kitana managed Quickshell dashboard tab

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Kitana.Cava as KitanaCava
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
    readonly property string albumArtSource: Services.MediaService.artSource()
    readonly property real progressInset: 8
    readonly property int controlRadius: 7
    readonly property int heroCardInset: 16
    readonly property int albumStagePadding: 56
    readonly property int maxAlbumCoverSize: 280
    readonly property int spectrumBarCount: 12
    readonly property bool spectrumActive: mediaActive
    property bool outputDevicePickerOpen: false
    property bool outputDevicePickerRendered: false

    Layout.fillWidth: true
    Layout.fillHeight: true

    // Keep MPRIS position bindings fresh only while this tab is visible.
    Timer {
        interval: 1000
        running: tabRoot.mediaActive && Services.MediaService.playing
        repeat: true
        triggeredOnStart: true
        onTriggered: Services.MediaService.refreshPosition()
    }

    Timer {
        id: outputDevicePickerHideTimer

        interval: 150
        onTriggered: if (!tabRoot.outputDevicePickerOpen)
            tabRoot.outputDevicePickerRendered = false
    }

    KitanaCava.CavaProvider {
        id: mediaSpectrum

        bars: tabRoot.spectrumBarCount
        frameRate: 30
        active: tabRoot.spectrumActive
    }

    onOutputDevicePickerOpenChanged: {
        if (outputDevicePickerOpen) {
            outputDevicePickerHideTimer.stop();
            outputDevicePickerRendered = true;
        } else {
            outputDevicePickerHideTimer.restart();
        }
    }

    // Media tab section layout: hero above output and spectrum cards.
    ColumnLayout {
        anchors.fill: parent
        spacing: tabRoot.panel.tabCardSpacing

        // Primary media section with artwork, metadata, seek, and playback controls.
        Rectangle {
            id: heroCard

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 250
            radius: tabRoot.panel.sectionRadius
            color: tabRoot.panel.sectionContainer
            border.color: tabRoot.panel.sectionBorder
            border.width: tabRoot.panel.sectionBorderWidth
            border.pixelAligned: false
            antialiasing: true
            clip: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: tabRoot.heroCardInset
                spacing: 18

                // Album artwork presentation block.
                Item {
                    id: albumStage

                    readonly property int coverSize: Math.round(Math.max(120, Math.min(tabRoot.maxAlbumCoverSize, heroCard.width * 0.34, height - tabRoot.albumStagePadding)))
                    readonly property int stageWidth: coverSize + tabRoot.albumStagePadding

                    Layout.minimumWidth: stageWidth
                    Layout.preferredWidth: stageWidth
                    Layout.maximumWidth: stageWidth
                    Layout.fillHeight: true

                    Rectangle {
                        id: albumBackdrop

                        anchors.fill: parent
                        radius: 18
                        color: Colors.alpha(Colors.bgPrimary, 0.46)
                        border.color: Colors.borderFaint
                        border.width: 1

                        Image {
                            id: albumBackdropImage

                            anchors.fill: parent
                            source: tabRoot.albumArtSource
                            sourceSize.width: width
                            sourceSize.height: height
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: false
                        }

                        Rectangle {
                            id: albumBackdropMask

                            anchors.fill: parent
                            radius: albumBackdrop.radius
                            visible: false
                            layer.enabled: true
                        }

                        MultiEffect {
                            anchors.fill: albumBackdropImage
                            source: albumBackdropImage
                            opacity: 0.10
                            visible: tabRoot.albumArtSource.length > 0 && albumBackdropImage.status === Image.Ready
                            maskEnabled: true
                            maskSource: albumBackdropMask
                        }

                        Rectangle {
                            id: albumFrame

                            width: albumStage.coverSize
                            height: width
                            anchors.centerIn: parent
                            radius: 8
                            color: Colors.bgPrimary
                            border.color: Colors.borderFaint
                            border.width: 1
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
                                radius: Math.max(0, albumFrame.radius - 1)
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
                                size: Math.round(albumFrame.width * 0.34)
                            }
                        }
                    }

                    Controls.Badge {
                        id: qualityBadge

                        anchors.left: albumBackdrop.left
                        anchors.top: albumBackdrop.top
                        anchors.leftMargin: 16
                        anchors.topMargin: 16
                        z: 3
                        width: Math.min(albumBackdrop.width - 32, Math.max(124, qualityBadge.implicitWidth))
                        text: Services.SystemStatus.audioQualityLabel
                        size: "sm"
                        hasBorder: true
                        colorVariant: "secondary"
                        icon: "media.note"
                        iconTone: "secondary"
                        horizontalPadding: 10
                        fontPixelSize: settings.textPixelSize - 2
                    }
                }

                // Metadata, progress, and controls stack.
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 0
                    spacing: 8
                    clip: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 1

                        Text {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            text: Services.MediaService.title
                            color: Colors.fgPrimary
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            wrapMode: Text.NoWrap
                            font.family: Typography.fontFamily
                            font.pixelSize: 25
                            font.weight: Font.Black
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            text: Services.MediaService.artist.length > 0 ? Services.MediaService.artist : "Unknown Artist"
                            color: Colors.fgSecondary
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize + 3
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            text: Services.MediaService.playerName
                            color: Colors.fgMuted
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize - 2
                            font.weight: Font.DemiBold
                        }
                    }

                    Item {
                        Layout.preferredHeight: 8
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 8

                        Controls.Badge {
                            text: Services.MediaService.status
                            size: "md"
                            colorVariant: Services.MediaService.playing ? "accent" : "secondary"
                        }

                        Controls.Badge {
                            Layout.preferredWidth: 150
                            text: Services.MediaService.album.length > 0 ? Services.MediaService.album : "No album"
                            size: "md"
                            colorVariant: "subtle"
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Item {
                        Layout.preferredHeight: 4
                    }

                    // Seekable track progress with elapsed and total time.
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 4

                        Rectangle {
                            id: progressTrack

                            Layout.fillWidth: true
                            Layout.preferredHeight: 8
                            radius: 4
                            color: Colors.bgTertiary

                            readonly property real fillRatio: Services.MediaService.hasProgress ? Math.max(0, Math.min(1, Services.MediaService.progress)) : 0

                            function ratioFromX(pointerX: real): real {
                                return Math.max(0, Math.min(1, (pointerX - tabRoot.progressInset) / Math.max(1, width - 2 * tabRoot.progressInset)));
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: tabRoot.progressInset + Math.max(0, parent.width - 2 * tabRoot.progressInset) * progressTrack.fillRatio
                                radius: parent.radius
                                color: Services.MediaService.hasProgress ? Colors.fgAccent : "transparent"
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

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: Services.MediaService.positionLabel
                                color: Colors.fgSecondary
                                font.family: Typography.fontFamily
                                font.pixelSize: settings.textPixelSize - 1
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: Services.MediaService.lengthLabel
                                color: Colors.fgSecondary
                                font.family: Typography.fontFamily
                                font.pixelSize: settings.textPixelSize - 1
                            }
                        }
                    }

                    // Playback controls and queue mode chips.
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 12

                        MediaButton {
                            iconName: "media.shuffle"
                            cornerRadius: tabRoot.controlRadius
                            visible: Services.MediaService.shuffleSupported
                            selected: Services.MediaService.shuffle
                            onClicked: Services.MediaService.toggleShuffle()
                        }

                        MediaButton {
                            iconName: "media.loop"
                            cornerRadius: tabRoot.controlRadius
                            visible: Services.MediaService.loopSupported
                            selected: Services.MediaService.looping
                            onClicked: Services.MediaService.cycleLoop()
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        MediaButton {
                            iconName: "media.previous"
                            cornerRadius: tabRoot.controlRadius
                            enabled: Services.MediaService.canPrevious
                            onClicked: Services.MediaService.previous()
                        }

                        MediaButton {
                            iconName: Services.MediaService.playing ? "media.pause" : "media.play"
                            cornerRadius: tabRoot.controlRadius
                            prominent: true
                            enabled: Services.MediaService.canTogglePlaying
                            onClicked: Services.MediaService.playPause()
                        }

                        MediaButton {
                            iconName: "media.next"
                            cornerRadius: tabRoot.controlRadius
                            enabled: Services.MediaService.canNext
                            onClicked: Services.MediaService.next()
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        MediaButton {
                            iconName: "media.stop"
                            cornerRadius: tabRoot.controlRadius
                            iconTone: "danger"
                            enabled: Services.MediaService.canStop
                            onClicked: Services.MediaService.stop()
                        }
                    }
                }
            }
        }

        // Lower media control sections.
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 134
            spacing: tabRoot.panel.tabCardSpacing

            // Audio output and volume section.
            Rectangle {
                id: outputControlCard

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 430
                radius: tabRoot.panel.sectionRadius
                color: tabRoot.panel.sectionContainer
                border.color: tabRoot.panel.sectionBorder
                border.width: tabRoot.panel.sectionBorderWidth
                border.pixelAligned: false
                antialiasing: true
                clip: false

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    // Output device identity and picker trigger.
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            radius: tabRoot.controlRadius
                            color: Colors.subtleSecondary
                            border.color: Colors.borderFaint
                            border.width: 1

                            Controls.Icon {
                                anchors.centerIn: parent
                                name: "audio.output"
                                tone: "accent"
                                size: settings.iconPixelSize
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: "OUTPUT DEVICE"
                                color: Colors.fgAccent
                                elide: Text.ElideRight
                                font.family: Typography.fontFamily
                                font.pixelSize: settings.textPixelSize - 2
                                font.letterSpacing: 1.6
                                font.weight: Font.Black
                            }

                            Text {
                                Layout.fillWidth: true
                                text: Services.SystemStatus.audioSink
                                color: Colors.fgPrimary
                                elide: Text.ElideRight
                                font.family: Typography.fontFamily
                                font.pixelSize: settings.textPixelSize + 1
                                font.weight: Font.DemiBold
                            }
                        }

                        Item {
                            id: outputDevicePickerLane

                            Layout.preferredWidth: 46
                            Layout.preferredHeight: 40

                            IconControlButton {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                iconName: "ui.more.vertical"
                                hoverColor: Colors.scrimSecondary
                                selected: tabRoot.outputDevicePickerOpen
                                onClicked: tabRoot.outputDevicePickerOpen = !tabRoot.outputDevicePickerOpen
                            }
                        }
                    }

                    // Compact mute, level, and percentage row.
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 6

                        IconControlButton {
                            buttonSize: 20
                            iconName: Services.SystemStatus.audioIconName
                            iconTone: "primary"
                            iconHorizontalAlignment: Text.AlignLeft
                            onClicked: Services.SystemStatus.toggleAudioMute()
                        }

                        Controls.ValueSlider {
                            id: audioLevelSlider

                            Layout.fillWidth: true
                            Layout.preferredHeight: 28
                            value: Services.SystemStatus.audioVolume
                            enabled: Services.SystemStatus.audioAvailable
                            fillColor: Services.SystemStatus.audioMuted ? Colors.borderFaint : Colors.fgAccent
                            handleColor: fillColor
                            onMoved: Services.SystemStatus.setAudioVolume(audioLevelSlider.value)
                        }

                        Text {
                            Layout.preferredWidth: Math.max(32, implicitWidth)
                            text: Services.SystemStatus.audioVolume + "%"
                            color: Services.SystemStatus.audioMuted ? Colors.fgSecondary : Colors.fgPrimary
                            horizontalAlignment: Text.AlignRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize + 1
                            font.weight: Font.Black
                        }
                    }
                }
            }

            // Live audio visualizer section with a fixed title divider.
            Rectangle {
                id: spectrumCard

                Layout.preferredWidth: 220
                Layout.fillHeight: true
                radius: tabRoot.panel.sectionRadius
                color: tabRoot.panel.sectionContainer
                border.color: tabRoot.panel.sectionBorder
                border.width: tabRoot.panel.sectionBorderWidth
                border.pixelAligned: false
                antialiasing: true
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    // Fixed header stays outside the animated bar layout.
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 18
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: Colors.borderFaint
                        }

                        Text {
                            text: "VISUALIZER"
                            color: Colors.fgAccent
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize - 3
                            font.letterSpacing: 1.6
                            font.weight: Font.Black
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: Colors.borderFaint
                        }
                    }

                    // Bar plot is isolated so animated heights do not relayout the header.
                    Item {
                        id: visualizerPlot

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        RowLayout {
                            anchors.fill: parent
                            spacing: 7

                            Repeater {
                                model: mediaSpectrum.values

                                Rectangle {
                                    required property real modelData
                                    readonly property real barValue: Math.max(0.04, Math.min(1, modelData))

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.max(8, visualizerPlot.height * barValue)
                                    Layout.alignment: Qt.AlignBottom
                                    radius: 3
                                    color: tabRoot.spectrumActive ? Colors.subtleAccent : Colors.bgTertiary
                                    opacity: tabRoot.spectrumActive ? 1 : 0.58
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Modal backdrop and click-away target for the output picker.
    Controls.PopupBackdrop {
        anchors.fill: parent
        open: tabRoot.outputDevicePickerOpen
        rendered: tabRoot.outputDevicePickerRendered
        scrimColor: Colors.alpha(Colors.bgPrimary, 0.36)
        z: 20
        onDismissed: tabRoot.outputDevicePickerOpen = false

        // Lightweight output device picker with subtle zebra rows.
        Rectangle {
            id: outputDevicePickerPopup

            readonly property point popupOrigin: outputControlCard.mapToItem(tabRoot, outputControlCard.width - width - 12, outputControlCard.height - height - 12)

            width: Math.min(330, Math.max(270, outputControlCard.width - 24))
            height: Math.min(250, outputDeviceList.implicitHeight + 50)
            x: Math.max(0, Math.min(tabRoot.width - width, popupOrigin.x))
            y: Math.max(0, Math.min(tabRoot.height - height, popupOrigin.y))
            opacity: tabRoot.outputDevicePickerOpen ? 1 : 0
            scale: tabRoot.outputDevicePickerOpen ? 1 : 0.92
            transformOrigin: Item.BottomRight
            radius: tabRoot.controlRadius
            color: Colors.bgPrimary
            border.color: Colors.borderFaint
            border.width: 1
            clip: true

            MouseArea {
                anchors.fill: parent
                onPressed: mouse => mouse.accepted = true
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutBack
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 9
                spacing: 6

                // Popup header with explicit dismiss affordance.
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: "Output Devices"
                        color: Colors.fgPrimary
                        elide: Text.ElideRight
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.DemiBold
                    }

                    Controls.CloseButton {
                        buttonSize: 22
                        iconSize: 12
                        variant: "light"
                        onClicked: tabRoot.outputDevicePickerOpen = false
                    }
                }

                Flickable {
                    id: outputDeviceFlickable

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: width
                    contentHeight: outputDeviceList.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true

                    Column {
                        id: outputDeviceList

                        width: outputDeviceFlickable.width
                        spacing: 1

                        Text {
                            width: parent.width
                            height: visible ? 38 : 0
                            visible: Services.SystemStatus.audioSinks.length === 0
                            text: "No output devices"
                            color: Colors.fgSecondary
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize
                        }

                        Repeater {
                            model: Services.SystemStatus.audioSinks

                            OutputDeviceRow {
                                required property int index
                                required property var modelData

                                rowIndex: index
                                sink: modelData
                            }
                        }
                    }
                }
            }
        }
    }

    component IconControlButton: Rectangle {
        id: buttonRoot

        property string iconName: Icons.defaultIcon
        property bool selected: false
        property int buttonSize: 34
        property string iconTone: selected ? "accent" : "primary"
        property int iconHorizontalAlignment: Text.AlignHCenter
        property color hoverColor: "transparent"

        signal clicked

        implicitWidth: buttonSize
        implicitHeight: buttonSize
        Layout.preferredWidth: buttonSize
        Layout.preferredHeight: buttonSize
        radius: tabRoot.controlRadius
        color: buttonMouse.containsMouse ? hoverColor : "transparent"
        border.width: 0

        Controls.Icon {
            anchors.fill: parent
            name: buttonRoot.iconName
            tone: !buttonRoot.enabled ? "disabled" : buttonRoot.iconTone
            size: settings.iconPixelSize - 1
            horizontalAlignment: buttonRoot.iconHorizontalAlignment
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent
            enabled: buttonRoot.enabled
            hoverEnabled: true
            cursorShape: buttonRoot.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: buttonRoot.clicked()
        }
    }

    component OutputDeviceRow: Rectangle {
        id: deviceRoot

        required property var sink
        property int rowIndex: 0
        readonly property bool active: Services.SystemStatus.audioSink === sink.name

        width: parent ? parent.width : 0
        height: 44
        radius: Math.max(3, tabRoot.controlRadius - 3)
        color: deviceMouse.containsMouse ? Colors.alpha(Colors.bgTertiary, 0.72) : (rowIndex % 2 === 0 ? Colors.alpha(Colors.bgTertiary, 0.28) : "transparent")

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 9

            Rectangle {
                Layout.preferredWidth: deviceRoot.active ? 3 : 0
                Layout.fillHeight: true
                Layout.topMargin: 8
                Layout.bottomMargin: 8
                radius: 2
                color: Colors.subtleAccent
            }

            Controls.Icon {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                name: deviceRoot.sink.iconName || "audio.output"
                tone: deviceRoot.active ? "accent" : "secondary"
                size: settings.iconPixelSize - 1
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: deviceRoot.sink.name
                    color: deviceRoot.active ? Colors.fgPrimary : Colors.fgSecondary
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.DemiBold
                }

                Text {
                    Layout.fillWidth: true
                    text: deviceRoot.active ? "Current output" : (deviceRoot.sink.subtitle || "Output device")
                    color: Colors.fgTertiary
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize - 2
                }
            }

            Controls.Icon {
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                visible: deviceRoot.active
                name: "ui.check"
                tone: "accent"
                size: settings.iconPixelSize - 2
            }
        }

        MouseArea {
            id: deviceMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Services.SystemStatus.setAudioSink(deviceRoot.sink.id);
                tabRoot.outputDevicePickerOpen = false;
            }
        }
    }
}
