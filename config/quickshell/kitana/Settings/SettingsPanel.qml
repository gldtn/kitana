// Kitana managed Quickshell settings panel

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../Components/Controls" as Controls
import "../Services" as Services
import "../custom" as Custom

// qmllint disable uncreatable-type
PanelWindow {
    id: root
    // qmllint enable uncreatable-type

    Custom.Settings { id: settings }

    property bool panelVisible: false
    property real revealProgress: 0
    property string activeTab: "bar"
    property alias backdropItem: backdrop

    function open(tab: string): void {
        const wasVisible = panelVisible;
        activeTab = tab || "bar";
        panelVisible = true;
        if (!wasVisible) {
            revealProgress = 0;
            revealAnimation.restart();
        }
        closeArea.forceActiveFocus();
    }

    function close(): void {
        panelVisible = false;
        revealProgress = 0;
    }

    function toggle(tab: string): void {
        const targetTab = tab || activeTab;
        if (panelVisible && activeTab === targetTab)
            close();
        else
            open(targetTab);
    }

    function modeTitle(mode: string): string {
        if (mode === "icons")
            return "Icons";
        if (mode === "full")
            return "Full";
        return "Compact";
    }

    function modeSubtitle(mode: string): string {
        if (mode === "icons")
            return "Symbol only";
        if (mode === "full")
            return "Full layout names";
        return "DWL / SCR labels";
    }

    // Settings panel IPC command bridge
    IpcHandler {
        target: "kitana-settings"

        function open(tab: string): void { root.open(tab || "bar"); }
        function close(): void { root.close(); }
        function toggle(tab: string): void { root.toggle(tab || "bar"); }
    }

    visible: panelVisible
    focusable: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-blurred-panel"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    // Full-screen close catcher
    MouseArea {
        id: closeArea
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.close()
        onClicked: root.close()
    }

    // Blurred settings panel backdrop
    Controls.BlurredBackdrop {
        id: backdrop

        anchors.fill: parent
    }

    // Main settings card
    Rectangle {
        id: card

        width: Math.min(820, parent.width - 72)
        height: Math.min(520, parent.height - 120)
        anchors.centerIn: parent
        opacity: root.revealProgress
        radius: 18
        color: Colors.bgPrimary
        border.color: Colors.borderFaint
        border.width: 1
        clip: true

        transform: Translate {
            y: (1 - root.revealProgress) * 14
        }

        // Prevent clicks inside card from closing panel
        MouseArea {
            anchors.fill: parent
            onPressed: mouse => mouse.accepted = true
        }

        // Settings tab chrome and content area
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // Settings tab selector row
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                TabButton { iconName: "workspace.layout"; label: "Bar"; tab: "bar" }
                TabButton { iconName: "settings"; label: "System"; tab: "system" }

                Item { Layout.fillWidth: true }

                Controls.CloseButton {
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: root.close()
                }
            }

            // Settings tab divider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.borderFaint
            }

            // Active settings tab loader
            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                sourceComponent: root.activeTab === "system" ? systemTab : barTab
            }
        }
    }

    // Settings card reveal animation
    NumberAnimation {
        id: revealAnimation
        target: root
        property: "revealProgress"
        to: 1
        duration: 140
        easing.type: Easing.OutCubic
    }

    // Reusable settings tab button
    component TabButton: Rectangle {
        id: tabRoot

        property string iconName: Icons.defaultIcon
        property string label: ""
        property string tab: ""
        readonly property bool selected: root.activeTab === tab

        Layout.preferredWidth: tabContent.implicitWidth + 22
        Layout.preferredHeight: 34
        radius: 10
        color: selected ? Colors.subtleAccent : (tabMouse.containsMouse ? Colors.bgTertiary : "transparent")
        border.color: selected ? Colors.borderAccent : "transparent"
        border.width: 1

        // Tab icon and label row
        Row {
            id: tabContent
            anchors.centerIn: parent
            spacing: 7

            Controls.Icon {
                height: tabRoot.height
                name: tabRoot.iconName
                tone: tabRoot.selected ? "accent" : "primary"
                sizeRole: "bar"
            }

            Text {
                height: tabRoot.height
                text: tabRoot.label
                color: Colors.fgPrimary
                verticalAlignment: Text.AlignVCenter
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }
        }

        // Tab selection click target
        MouseArea {
            id: tabMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.activeTab = tabRoot.tab
        }
    }

    // Reusable system setting row
    component SettingRow: Rectangle {
        id: rowRoot

        property string iconName: Icons.defaultIcon
        property string title: ""
        property string subtitle: ""
        property bool active: false

        signal clicked

        Layout.fillWidth: true
        Layout.preferredHeight: 52
        radius: 12
        color: rowMouse.containsMouse ? Colors.bgTertiary : Colors.bgTertiary
        border.color: active ? Colors.borderAccent : Colors.borderFaint
        border.width: 1

        // Setting icon and labels
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Controls.Icon {
                Layout.preferredWidth: 24
                name: rowRoot.iconName
                tone: rowRoot.active ? "accent" : "primary"
                size: settings.iconPixelSize + 1
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: rowRoot.title
                    color: Colors.fgPrimary
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.Bold
                }

                Text {
                    Layout.fillWidth: true
                    text: rowRoot.subtitle
                    color: Colors.fgSecondary
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize - 1
                }
            }
        }

        // Setting row click target
        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: rowRoot.clicked()
        }
    }

    // Workspace layout display option card
    component OptionButton: Rectangle {
        id: optionRoot

        property string mode: "compact"
        readonly property bool selected: Services.UiPreferences.layoutPillDisplayMode === mode

        Layout.fillWidth: true
        Layout.preferredHeight: 88
        radius: 13
        color: selected ? Colors.subtleAccent : (optionMouse.containsMouse ? Colors.bgTertiary : Colors.bgTertiary)
        border.color: selected ? Colors.borderAccent : Colors.borderFaint
        border.width: 1

        // Option icon and description
        Column {
            anchors.centerIn: parent
            width: parent.width - 24
            spacing: 5

            Controls.Icon {
                anchors.horizontalCenter: parent.horizontalCenter
                name: Icons.workspaceLayoutName(optionRoot.mode === "icons" ? "dwindle" : optionRoot.mode)
                tone: optionRoot.selected ? "accent" : "primary"
                size: settings.iconPixelSize + 2
            }

            Text {
                width: parent.width
                text: root.modeTitle(optionRoot.mode)
                color: Colors.fgPrimary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.Bold
            }

            Text {
                width: parent.width
                text: root.modeSubtitle(optionRoot.mode)
                color: Colors.fgSecondary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize - 1
            }
        }

        // Option selection click target
        MouseArea {
            id: optionMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Services.UiPreferences.setLayoutPillDisplayMode(optionRoot.mode)
        }
    }

    // Compact button used by geometry controls
    component GeometryActionButton: Rectangle {
        id: actionRoot

        property string label: ""

        signal clicked

        Layout.preferredWidth: labelText.implicitWidth + 18
        Layout.preferredHeight: 30
        radius: 9
        opacity: enabled ? 1 : 0.45
        color: actionMouse.containsMouse && enabled ? Colors.subtleAccent : Colors.bgTertiary
        border.color: actionMouse.containsMouse && enabled ? Colors.borderAccent : Colors.borderFaint
        border.width: 1

        Text {
            id: labelText

            anchors.centerIn: parent
            text: actionRoot.label
            color: Colors.fgPrimary
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.Bold
        }

        MouseArea {
            id: actionMouse

            anchors.fill: parent
            enabled: actionRoot.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: actionRoot.clicked()
        }
    }

    // Numeric geometry preference row
    component GeometryStepper: Rectangle {
        id: stepRoot

        property string title: ""
        property string subtitle: ""
        property int value: 0
        property int minimum: 0
        property int maximum: 100
        property int step: 1

        signal valueRequested(int requestedValue)

        Layout.fillWidth: true
        Layout.preferredHeight: 48
        radius: 12
        color: Colors.bgTertiary
        border.color: Colors.borderFaint
        border.width: 1

        // Label, value, and increment controls
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: stepRoot.title
                    color: Colors.fgPrimary
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.Bold
                }

                Text {
                    Layout.fillWidth: true
                    text: stepRoot.subtitle
                    color: Colors.fgSecondary
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize - 1
                }
            }

            GeometryActionButton {
                label: "-"
                enabled: stepRoot.value > stepRoot.minimum
                onClicked: stepRoot.valueRequested(Math.max(stepRoot.minimum, stepRoot.value - stepRoot.step))
            }

            Rectangle {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 30
                radius: 9
                color: Colors.bgSecondary
                border.color: Colors.borderFaint
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: stepRoot.value + " px"
                    color: Colors.fgPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.DemiBold
                }
            }

            GeometryActionButton {
                label: "+"
                enabled: stepRoot.value < stepRoot.maximum
                onClicked: stepRoot.valueRequested(Math.min(stepRoot.maximum, stepRoot.value + stepRoot.step))
            }
        }
    }

    // Bar settings tab content
    Component {
        id: barTab

        // Scrollable bar settings stack
        Flickable {
            clip: true
            contentWidth: width
            contentHeight: barStack.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: barStack

                width: parent.width
                spacing: 12

                Text {
                    Layout.fillWidth: true
                    text: "Bar"
                    color: Colors.fgPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize + 4
                    font.weight: Font.Bold
                }

                // Workspace layout options card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 176
                    radius: 14
                    color: Colors.bgSecondary
                    border.color: Colors.borderFaint
                    border.width: 1

                    // Workspace layout options content
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Text {
                            Layout.fillWidth: true
                            text: "Workspace layout control"
                            color: Colors.fgPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize
                            font.weight: Font.Bold
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            OptionButton { mode: "icons" }
                            OptionButton { mode: "compact" }
                            OptionButton { mode: "full" }
                        }
                    }
                }

                // Persistent bar geometry controls card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 276
                    radius: 14
                    color: Colors.bgSecondary
                    border.color: Colors.borderFaint
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    Layout.fillWidth: true
                                    text: "Bar geometry"
                                    color: Colors.fgPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: settings.textPixelSize
                                    font.weight: Font.Bold
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: "Stored live; defaults still come from custom settings."
                                    color: Colors.fgSecondary
                                    elide: Text.ElideRight
                                    font.family: Typography.fontFamily
                                    font.pixelSize: settings.textPixelSize - 1
                                }
                            }

                            GeometryActionButton {
                                label: "Reset"
                                onClicked: Services.UiPreferences.resetBarGeometry()
                            }
                        }

                        GeometryStepper {
                            title: "Bar height"
                            subtitle: "Default " + Services.UiPreferences.defaultPanelHeight + " px, reserved edge height"
                            value: Services.UiPreferences.panelHeight
                            minimum: 24
                            maximum: 72
                            onValueRequested: requestedValue => Services.UiPreferences.setPanelHeight(requestedValue)
                        }

                        GeometryStepper {
                            title: "Pill height"
                            subtitle: "Default " + Services.UiPreferences.defaultPillHeight + " px, capped by bar height"
                            value: Services.UiPreferences.pillHeight
                            minimum: 18
                            maximum: Services.UiPreferences.panelHeight
                            onValueRequested: requestedValue => Services.UiPreferences.setPillHeight(requestedValue)
                        }

                        GeometryStepper {
                            title: "Top margin"
                            subtitle: "Default " + Services.UiPreferences.defaultTopMargin + " px, distance from screen edge"
                            value: Services.UiPreferences.topMargin
                            minimum: 0
                            maximum: 32
                            onValueRequested: requestedValue => Services.UiPreferences.setTopMargin(requestedValue)
                        }

                        GeometryStepper {
                            title: "Pill radius"
                            subtitle: "Default " + Services.UiPreferences.defaultPillRadius + " px, capped at half pill height"
                            value: Services.UiPreferences.pillRadius
                            minimum: 0
                            maximum: Math.round(Services.UiPreferences.pillHeight / 2)
                            onValueRequested: requestedValue => Services.UiPreferences.setPillRadius(requestedValue)
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "The control toggles the focused workspace between dwindle and scrolling without changing your Hyprland default layout."
                    color: Colors.fgSecondary
                    wrapMode: Text.WordWrap
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    // System settings tab content
    Component {
        id: systemTab

        // System settings stack
        ColumnLayout {
            spacing: 12

            Text {
                Layout.fillWidth: true
                text: "System"
                color: Colors.fgPrimary
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize + 4
                font.weight: Font.Bold
            }

            // Do not disturb toggle row
            SettingRow {
                iconName: "notifications.on"
                title: "Do Not Disturb"
                subtitle: Services.NotificationService.doNotDisturb ? "Notifications paused" : "Notifications visible"
                active: Services.NotificationService.doNotDisturb
                onClicked: Services.NotificationService.toggleDoNotDisturb()
            }

            // Caffeine toggle row
            SettingRow {
                iconName: Services.CaffeineService.iconName
                title: "Caffeine"
                subtitle: Services.CaffeineService.enabled ? "Idle inhibit on" : "Idle inhibit off"
                active: Services.CaffeineService.enabled
                onClicked: Services.CaffeineService.toggle()
            }

            Text {
                Layout.fillWidth: true
                text: "Network, Bluetooth, and audio routing stay in the control panel."
                color: Colors.fgSecondary
                wrapMode: Text.WordWrap
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
            }

            Item { Layout.fillHeight: true }
        }
    }
}
