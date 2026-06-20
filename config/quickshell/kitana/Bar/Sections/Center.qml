// Kitana managed Quickshell bar section

import QtQuick
import "../.."
import "../Items" as Items
import "../../Components/Controls" as Controls
import "../../Services" as Services
import "../../custom" as Custom

Item {
    id: root

    Custom.Settings {
        id: settings
    }

    property var dashboardPanel: null
    property var panelScreen: null
    property real sourceX: 0
    property real sourceY: 0
    property bool embedded: false
    property bool interactive: true
    property bool hovered: false
    property bool forceDashboardIcon: false
    property bool hideWhenDashboardActive: true
    readonly property bool dashboardActive: hideWhenDashboardActive && dashboardPanel !== null && dashboardPanel.islandActive
    readonly property bool dashboardIconVisible: (forceDashboardIcon || (interactive && (hovered || hoverHandler.hovered))) && !dashboardActive

    implicitWidth: Math.max(dateTime.implicitWidth, Services.UiPreferences.pillHeight) + Services.UiPreferences.clockHorizontalPadding
    implicitHeight: Services.UiPreferences.pillHeight
    width: implicitWidth
    height: implicitHeight
    opacity: dashboardActive ? 0 : 1
    visible: opacity > 0

    // Center island pill background
    Rectangle {
        anchors.fill: parent
        visible: !root.embedded
        radius: Services.UiPreferences.pillRadius
        color: Colors.barItemBg
        border.color: Colors.barItemBorder
        border.width: settings.borderWidth
    }

    HoverHandler {
        id: hoverHandler

        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    // Date and time shown by default in the collapsed island.
    Items.DateTime {
        id: dateTime

        anchors.centerIn: parent
        opacity: root.dashboardIconVisible ? 0 : 1
        visible: !root.dashboardIconVisible

        Behavior on opacity {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }
    }

    // Hover affordance for the whole clickable dashboard island.
    Controls.Icon {
        anchors.centerIn: parent
        name: "dashboard"
        tone: "accent"
        sizeRole: "bar"
        opacity: root.dashboardIconVisible ? 1 : 0
        visible: root.dashboardIconVisible || opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }
    }
}
