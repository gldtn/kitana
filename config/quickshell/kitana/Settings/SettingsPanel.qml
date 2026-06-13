// Kitana managed Quickshell settings panel

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../Components/Controls" as Controls
import "../Services" as Services
import "../custom" as Custom

PanelWindow {
    id: root

    Custom.Settings { id: settings }

    property real revealProgress: 0
    property string activeTab: "bar"

    function open(tab: string): void {
        const wasVisible = visible;
        activeTab = tab || "bar";
        visible = true;
        if (!wasVisible) {
            revealProgress = 0;
            revealAnimation.restart();
        }
        closeArea.forceActiveFocus();
    }

    function close(): void {
        visible = false;
        revealProgress = 0;
    }

    function toggle(tab: string): void {
        const targetTab = tab || activeTab;
        if (visible && activeTab === targetTab)
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

    IpcHandler {
        target: "kitana-settings"

        function open(tab: string): void { root.open(tab || "bar"); }
        function close(): void { root.close(); }
        function toggle(tab: string): void { root.toggle(tab || "bar"); }
    }

    visible: false
    focusable: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    BackgroundEffect.blurRegion: Region { item: backdrop }

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    MouseArea {
        id: closeArea
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.close()
        onClicked: root.close()
    }

    Controls.BlurredBackdrop {
        id: backdrop

        anchors.fill: parent
    }

    Rectangle {
        id: card

        width: Math.min(820, parent.width - 72)
        height: Math.min(520, parent.height - 120)
        anchors.centerIn: parent
        opacity: root.revealProgress
        radius: 18
        color: Colors.panelBackground
        border.color: Colors.panelBorder
        border.width: 1
        clip: true

        transform: Translate {
            y: (1 - root.revealProgress) * 14
        }

        MouseArea {
            anchors.fill: parent
            onPressed: mouse => mouse.accepted = true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                TabButton { icon: Icons.layout; label: "Bar"; tab: "bar" }
                TabButton { icon: Icons.settings; label: "System"; tab: "system" }

                Item { Layout.fillWidth: true }

                Controls.Icon {
                    icon: Icons.settings
                    color: Colors.accentForeground
                    size: settings.iconPixelSize + 1
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colors.panelBorder
            }

            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                sourceComponent: root.activeTab === "system" ? systemTab : barTab
            }
        }
    }

    NumberAnimation {
        id: revealAnimation
        target: root
        property: "revealProgress"
        to: 1
        duration: 140
        easing.type: Easing.OutCubic
    }

    component TabButton: Rectangle {
        id: tabRoot

        property string icon: ""
        property string label: ""
        property string tab: ""
        readonly property bool selected: root.activeTab === tab

        Layout.preferredWidth: tabContent.implicitWidth + 22
        Layout.preferredHeight: 34
        radius: 10
        color: selected ? Colors.panelButtonBackgroundActive : (tabMouse.containsMouse ? Colors.panelButtonBackgroundHover : "transparent")
        border.color: selected ? Colors.panelButtonBorderActive : "transparent"
        border.width: 1

        Row {
            id: tabContent
            anchors.centerIn: parent
            spacing: 7

            Controls.Icon {
                height: tabRoot.height
                icon: tabRoot.icon
                color: tabRoot.selected ? Colors.accentForeground : Colors.primaryForeground
                size: settings.iconPixelSize
            }

            Text {
                height: tabRoot.height
                text: tabRoot.label
                color: Colors.primaryForeground
                verticalAlignment: Text.AlignVCenter
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }
        }

        MouseArea {
            id: tabMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.activeTab = tabRoot.tab
        }
    }

    component SettingRow: Rectangle {
        id: rowRoot

        property string icon: ""
        property string title: ""
        property string subtitle: ""
        property bool active: false

        signal clicked

        Layout.fillWidth: true
        Layout.preferredHeight: 52
        radius: 12
        color: rowMouse.containsMouse ? Colors.panelButtonBackgroundHover : Colors.panelCardBackground
        border.color: active ? Colors.panelButtonBorderActive : Colors.panelBorder
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Controls.Icon {
                Layout.preferredWidth: 24
                icon: rowRoot.icon
                color: rowRoot.active ? Colors.accentForeground : Colors.primaryForeground
                size: settings.iconPixelSize + 1
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: rowRoot.title
                    color: Colors.primaryForeground
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.Bold
                }

                Text {
                    Layout.fillWidth: true
                    text: rowRoot.subtitle
                    color: Colors.mutedForeground
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize - 1
                }
            }
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: rowRoot.clicked()
        }
    }

    component OptionButton: Rectangle {
        id: optionRoot

        property string mode: "compact"
        readonly property bool selected: Services.UiPreferences.layoutPillDisplayMode === mode

        Layout.fillWidth: true
        Layout.preferredHeight: 88
        radius: 13
        color: selected ? Colors.panelButtonBackgroundActive : (optionMouse.containsMouse ? Colors.panelButtonBackgroundHover : Colors.panelCardBackground)
        border.color: selected ? Colors.panelButtonBorderActive : Colors.panelBorder
        border.width: 1

        Column {
            anchors.centerIn: parent
            width: parent.width - 24
            spacing: 5

            Controls.Icon {
                anchors.horizontalCenter: parent.horizontalCenter
                icon: Icons.workspaceLayout(optionRoot.mode === "icons" ? "dwindle" : optionRoot.mode)
                color: optionRoot.selected ? Colors.accentForeground : Colors.primaryForeground
                size: settings.iconPixelSize + 2
            }

            Text {
                width: parent.width
                text: root.modeTitle(optionRoot.mode)
                color: Colors.primaryForeground
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
                color: Colors.mutedForeground
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize - 1
            }
        }

        MouseArea {
            id: optionMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Services.UiPreferences.setLayoutPillDisplayMode(optionRoot.mode)
        }
    }

    Component {
        id: barTab

        ColumnLayout {
            spacing: 12

            Text {
                Layout.fillWidth: true
                text: "Bar"
                color: Colors.primaryForeground
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize + 4
                font.weight: Font.Bold
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 176
                radius: 14
                color: Colors.panelContainerBackground
                border.color: Colors.panelContainerBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Text {
                        Layout.fillWidth: true
                        text: "Workspace layout control"
                        color: Colors.primaryForeground
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

            Text {
                Layout.fillWidth: true
                text: "The control toggles the focused workspace between dwindle and scrolling without changing your Hyprland default layout."
                color: Colors.mutedForeground
                wrapMode: Text.WordWrap
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
            }

            Item { Layout.fillHeight: true }
        }
    }

    Component {
        id: systemTab

        ColumnLayout {
            spacing: 12

            Text {
                Layout.fillWidth: true
                text: "System"
                color: Colors.primaryForeground
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize + 4
                font.weight: Font.Bold
            }

            SettingRow {
                icon: Icons.notifications
                title: "Do Not Disturb"
                subtitle: Services.NotificationService.doNotDisturb ? "Notifications paused" : "Notifications visible"
                active: Services.NotificationService.doNotDisturb
                onClicked: Services.NotificationService.toggleDoNotDisturb()
            }

            SettingRow {
                icon: Services.CaffeineService.icon
                title: "Caffeine"
                subtitle: Services.CaffeineService.enabled ? "Idle inhibit on" : "Idle inhibit off"
                active: Services.CaffeineService.enabled
                onClicked: Services.CaffeineService.toggle()
            }

            Text {
                Layout.fillWidth: true
                text: "Network, Bluetooth, and audio routing stay in the quick system panel."
                color: Colors.mutedForeground
                wrapMode: Text.WordWrap
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
            }

            Item { Layout.fillHeight: true }
        }
    }
}
