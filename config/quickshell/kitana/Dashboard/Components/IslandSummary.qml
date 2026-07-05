// Kitana managed Quickshell dashboard component

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Kitana.Cava as KitanaCava
import "../.."
import "../../Components/Controls" as Controls
import "../../Services" as Services
import "../../custom" as Custom

Item {
    id: root

    Custom.Settings {
        id: settings
    }

    property var dashboardPanel: null
    property string summaryMode: "auto"
    property bool mediaDetailsRevealed: false

    readonly property var weatherCondition: dashboardPanel && dashboardPanel.weather && dashboardPanel.weather.current_condition ? dashboardPanel.weather.current_condition[0] : null
    readonly property string weatherTemperature: weatherCondition && dashboardPanel ? dashboardPanel.tempValue(weatherCondition, "temp_C", "temp_F") : ""
    readonly property bool weatherVisible: weatherTemperature.length > 0 && weatherTemperature !== "--"
    readonly property bool mediaAutoVisible: Services.MediaService.playing
    readonly property bool mediaVisible: summaryMode === "media" || (summaryMode === "auto" && mediaAutoVisible)
    readonly property bool mediaExpanded: mediaVisible && mediaHover.hovered
    readonly property bool spectrumActive: mediaVisible && dashboardPanel !== null && !dashboardPanel.expandedSurface
    readonly property string compactOpenTab: mediaVisible ? "media" : "datetime"
    readonly property int mediaInset: dashboardPanel && dashboardPanel.tabCardSpacing > 0 ? dashboardPanel.tabCardSpacing : 12
    readonly property int spectrumCompactBarCount: 8
    readonly property int spectrumBarWidth: 7
    readonly property int spectrumBarSpacing: 5
    readonly property int spectrumExpandedBarCount: Math.max(spectrumCompactBarCount, Math.floor((mediaExpandedWidth - 2 * mediaInset + spectrumBarSpacing) / (spectrumBarWidth + spectrumBarSpacing)))
    readonly property int spectrumVisibleBarCount: spectrumExpandedBarCount
    readonly property int spectrumFirstVisibleBar: Math.max(0, Math.floor((spectrumExpandedBarCount - spectrumVisibleBarCount) / 2))
    readonly property int spectrumExpandedWidth: spectrumExpandedBarCount * spectrumBarWidth + Math.max(0, spectrumExpandedBarCount - 1) * spectrumBarSpacing
    readonly property int mediaCompactWidth: spectrumExpandedWidth
    readonly property int mediaExpandedWidth: 244
    readonly property int mediaExpandedHeight: Math.max(126, visualizerHeight + mediaDetailsHeight + mediaControlsHeight + 2 * mediaInset + mediaVisualizerDetailsGap + mediaDetailsControlsGap)
    readonly property int mediaVisualizerDetailsGap: 7
    readonly property int mediaDetailsControlsGap: Math.max(9, Math.round(mediaInset * 0.75))
    readonly property int mediaDetailsHeight: Math.round(settings.textPixelSize * 3)
    readonly property int mediaControlsHeight: 24
    readonly property int visualizerHeight: mediaExpanded ? 24 : Math.max(16, Services.UiPreferences.pillHeight - 14)

    implicitHeight: mediaVisible ? (mediaExpanded ? mediaExpandedHeight : Services.UiPreferences.pillHeight) : Services.UiPreferences.pillHeight
    implicitWidth: mediaVisible ? (mediaExpanded ? mediaExpandedWidth : mediaCompactWidth) : clockRow.implicitWidth
    width: implicitWidth
    height: implicitHeight
    clip: mediaVisible

    onMediaExpandedChanged: {
        mediaRevealTimer.stop();
        if (mediaExpanded) {
            mediaDetailsRevealed = false;
            mediaRevealTimer.restart();
        } else {
            mediaDetailsRevealed = false;
        }
    }

    function cycleSummaryMode(): void {
        if (summaryMode === "auto") {
            summaryMode = mediaVisible ? "datetime" : "media";
            return;
        }

        if (summaryMode === "datetime") {
            summaryMode = "media";
            return;
        }

        summaryMode = "auto";
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 280
            easing.type: Easing.OutQuint
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 280
            easing.type: Easing.OutQuint
        }
    }

    KitanaCava.CavaProvider {
        id: summarySpectrum

        bars: root.spectrumExpandedBarCount
        frameRate: 24
        active: root.spectrumActive
    }

    Timer {
        id: mediaRevealTimer

        interval: 140
        onTriggered: if (root.mediaExpanded)
            root.mediaDetailsRevealed = true
    }

    // Date, time, and weather summary for the collapsed island.
    Row {
        id: clockRow

        anchors.centerIn: parent
        visible: !root.mediaVisible
        spacing: 10

        property date now: new Date()

        // Current date label
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDate(clockRow.now, "ddd MMM d")
            textFormat: Text.PlainText
            color: Colors.barItemFg
            font.family: Typography.fontFamily
            font.pixelSize: settings.clockPixelSize
            font.weight: Font.DemiBold
        }

        // Date/time separator dot
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "•"
            textFormat: Text.PlainText
            color: Colors.barItemFg
            font.family: Typography.fontFamily
            font.pixelSize: settings.clockPixelSize - 1
            font.weight: Font.DemiBold
        }

        // Current time label
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatTime(clockRow.now, "h:mm AP")
            textFormat: Text.PlainText
            color: Colors.barItemFg
            font.family: Typography.fontFamily
            font.pixelSize: settings.clockPixelSize
            font.weight: Font.DemiBold
        }

        // Time/weather separator dot
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.weatherVisible
            text: "•"
            textFormat: Text.PlainText
            color: Colors.barItemFg
            font.family: Typography.fontFamily
            font.pixelSize: settings.clockPixelSize - 1
            font.weight: Font.DemiBold
        }

        // Current weather icon and temperature
        Row {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.weatherVisible
            spacing: 5

            Controls.Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: "weather.default"
                tone: "primary"
                sizeRole: "bar"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.weatherTemperature
                textFormat: Text.PlainText
                color: Colors.barItemFg
                font.family: Typography.fontFamily
                font.pixelSize: settings.clockPixelSize
                font.weight: Font.DemiBold
            }
        }

        // Clock refresh timer
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockRow.now = new Date()
        }
    }

    // Compact media summary expands downward on hover with track details and controls.
    Item {
        id: mediaSummary

        anchors.fill: parent
        visible: root.mediaVisible

        HoverHandler {
            id: mediaHover
        }

        Column {
            id: mediaColumn

            anchors.horizontalCenter: parent.horizontalCenter
            y: root.mediaExpanded ? root.mediaInset : Math.round((parent.height - height) / 2)
            width: root.mediaExpanded ? parent.width - 2 * root.mediaInset : parent.width
            spacing: 0

            Behavior on y {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutQuint
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutQuint
                }
            }

            Behavior on spacing {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutQuint
                }
            }

            Item {
                id: visualizerPlot

                width: parent.width
                height: root.visualizerHeight

                Behavior on height {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.OutQuint
                    }
                }

                RowLayout {
                    anchors.centerIn: parent
                    height: parent.height
                    spacing: root.spectrumBarSpacing

                    Repeater {
                        model: summarySpectrum.values

                        Rectangle {
                            required property int index
                            required property real modelData
                            readonly property real barValue: Math.max(0.08, Math.min(1, modelData))

                            visible: index >= root.spectrumFirstVisibleBar && index < root.spectrumFirstVisibleBar + root.spectrumVisibleBarCount
                            Layout.preferredWidth: root.spectrumBarWidth
                            Layout.preferredHeight: Math.max(4, visualizerPlot.height * barValue)
                            Layout.alignment: Qt.AlignBottom
                            radius: Math.min(root.spectrumBarWidth / 2, 3)
                            color: root.spectrumActive ? Colors.subtleAccent : Colors.bgTertiary
                            opacity: root.spectrumActive ? 1 : 0.58
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: root.mediaExpanded ? root.mediaVisualizerDetailsGap : 0

                Behavior on height {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.OutQuint
                    }
                }
            }

            Item {
                width: parent.width
                height: root.mediaExpanded ? root.mediaDetailsHeight : 0
                clip: true
                opacity: root.mediaDetailsRevealed ? 1 : 0

                Behavior on height {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.OutQuint
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 190
                        easing.type: Easing.OutCubic
                    }
                }

                Column {
                    anchors.fill: parent
                    spacing: 2

                    MarqueeText {
                        width: parent.width
                        text: Services.MediaService.title
                        textColor: Colors.barItemFg
                        fontPixelSize: settings.textPixelSize + 1
                        fontWeight: Font.DemiBold
                        active: root.mediaDetailsRevealed
                    }

                    MarqueeText {
                        width: parent.width
                        text: Services.MediaService.artist.length > 0 ? Services.MediaService.artist : Services.MediaService.playerName
                        textColor: Colors.fgSecondary
                        fontPixelSize: settings.textPixelSize - 1
                        active: root.mediaDetailsRevealed
                    }
                }
            }

            Item {
                width: parent.width
                height: root.mediaExpanded ? root.mediaDetailsControlsGap : 0

                Behavior on height {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.OutQuint
                    }
                }
            }

            Item {
                width: parent.width
                height: root.mediaExpanded ? root.mediaControlsHeight : 0
                clip: true
                opacity: root.mediaDetailsRevealed ? 1 : 0

                Behavior on height {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.OutQuint
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 190
                        easing.type: Easing.OutCubic
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6

                    MediaControlButton {
                        iconName: "media.previous"
                        enabled: Services.MediaService.canPrevious
                        onClicked: Services.MediaService.previous()
                    }

                    MediaControlButton {
                        iconName: Services.MediaService.playing ? "media.pause" : "media.play"
                        enabled: Services.MediaService.canTogglePlaying
                        prominent: true
                        onClicked: Services.MediaService.playPause()
                    }

                    MediaControlButton {
                        iconName: "media.next"
                        enabled: Services.MediaService.canNext
                        onClicked: Services.MediaService.next()
                    }
                }
            }
        }
    }

    // Single-line marquee for long media metadata with soft edge fades.
    component MarqueeText: Item {
        id: marqueeRoot

        property string text: ""
        property color textColor: Colors.barItemFg
        property int fontPixelSize: settings.textPixelSize
        property int fontWeight: Font.Normal
        property bool active: false
        readonly property bool overflowing: textItem.implicitWidth > width + 1
        readonly property real scrollDistance: Math.max(0, textItem.implicitWidth - width)
        readonly property int scrollDuration: Math.max(3200, Math.round(scrollDistance * 48))

        implicitHeight: textItem.implicitHeight
        height: implicitHeight
        clip: true

        onTextChanged: resetPosition()
        onWidthChanged: resetPosition()
        onActiveChanged: resetPosition()
        onOverflowingChanged: resetPosition()

        function resetPosition(): void {
            textItem.x = overflowing ? 0 : Math.round((width - textItem.implicitWidth) / 2);
        }

        Component.onCompleted: resetPosition()

        Text {
            id: textItem

            y: Math.round((parent.height - implicitHeight) / 2)
            text: marqueeRoot.text
            textFormat: Text.PlainText
            color: marqueeRoot.textColor
            maximumLineCount: 1
            wrapMode: Text.NoWrap
            font.family: Typography.fontFamily
            font.pixelSize: marqueeRoot.fontPixelSize
            font.weight: marqueeRoot.fontWeight
        }

        SequentialAnimation {
            running: marqueeRoot.active && marqueeRoot.overflowing
            loops: Animation.Infinite
            onStopped: marqueeRoot.resetPosition()

            PauseAnimation {
                duration: 900
            }

            NumberAnimation {
                target: textItem
                property: "x"
                to: -marqueeRoot.scrollDistance
                duration: marqueeRoot.scrollDuration
                easing.type: Easing.InOutQuad
            }

            PauseAnimation {
                duration: 900
            }

            NumberAnimation {
                target: textItem
                property: "x"
                to: 0
                duration: Math.max(1600, Math.round(marqueeRoot.scrollDuration * 0.62))
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.min(18, parent.width / 3)
            visible: marqueeRoot.overflowing
            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop {
                    position: 0
                    color: Colors.barItemBg
                }

                GradientStop {
                    position: 1
                    color: "transparent"
                }
            }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.min(18, parent.width / 3)
            visible: marqueeRoot.overflowing
            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop {
                    position: 0
                    color: "transparent"
                }

                GradientStop {
                    position: 1
                    color: Colors.barItemBg
                }
            }
        }
    }

    component MediaControlButton: Rectangle {
        id: buttonRoot

        property string iconName: Icons.defaultIcon
        property bool prominent: false

        signal clicked

        width: prominent ? 28 : 24
        height: 24
        radius: 8
        color: !enabled ? Colors.subtlePrimary : (buttonMouse.containsMouse ? Colors.subtleAccent : Colors.subtleSecondary)
        border.color: !enabled ? Colors.borderFaint : (prominent ? Colors.borderAccent : Colors.borderFaint)
        border.width: 0.6
        border.pixelAligned: false
        antialiasing: true
        opacity: enabled ? 1 : 0.46

        Controls.Icon {
            anchors.fill: parent
            name: buttonRoot.iconName
            tone: !buttonRoot.enabled ? "disabled" : (buttonRoot.prominent ? "accent" : "primary")
            size: buttonRoot.prominent ? settings.iconPixelSize : settings.iconPixelSize - 2
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent
            enabled: buttonRoot.enabled
            hoverEnabled: true
            cursorShape: buttonRoot.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: mouse => {
                buttonRoot.clicked();
                mouse.accepted = true;
            }
        }
    }
}
