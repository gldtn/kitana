// Kitana managed Quickshell settings panel

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
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

    Custom.Settings {
        id: settings
    }

    property bool panelVisible: false
    property real revealProgress: 0
    property string activeTab: "bar"

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

    function workspaceLayoutOptions(): var {
        return [
            {
                value: "icons",
                label: "Icons",
                iconName: "workspace.layout"
            },
            {
                value: "compact",
                label: "Compact",
                iconName: "workspace.layout.dwindle"
            },
            {
                value: "full",
                label: "Full",
                iconName: "workspace.layout.scrolling"
            }
        ];
    }

    function loginMonitorOptions(): var {
        const options = [
            {
                value: "",
                label: "Automatic",
                iconName: "settings",
                enabled: !Services.LoginMonitor.saving
            }
        ];
        const monitors = Services.LoginMonitor.monitors || [];

        for (let i = 0; i < monitors.length; i++) {
            const monitor = monitors[i];
            options.push({
                value: monitor.selector || monitor.name || (monitor.description ? "desc:" + monitor.description : ""),
                label: monitor.displayName || monitor.name || "Monitor",
                iconName: "display.monitor",
                enabled: !Services.LoginMonitor.saving
            });
        }

        return options;
    }

    function loginMonitorSelection(): string {
        const monitors = Services.LoginMonitor.monitors || [];

        for (let i = 0; i < monitors.length; i++) {
            const monitor = monitors[i];
            if (Services.LoginMonitor.selectorMatches(monitor))
                return monitor.selector || monitor.name || (monitor.description ? "desc:" + monitor.description : "");
        }

        return Services.LoginMonitor.selector || "";
    }

    // Settings panel IPC command bridge
    IpcHandler {
        target: "kitana-settings"

        function open(tab: string): void {
            root.open(tab || "bar");
        }
        function close(): void {
            root.close();
        }
        function toggle(tab: string): void {
            root.toggle(tab || "bar");
        }
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

        readonly property color sectionContainer: Colors.bgSecondary
        readonly property color sectionBorder: Colors.borderFaint
        readonly property real sectionBorderWidth: 0.6

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

                TabButton {
                    iconName: "workspace.layout"
                    label: "Bar"
                    tab: "bar"
                }
                TabButton {
                    iconName: "settings"
                    label: "System"
                    tab: "system"
                }

                Item {
                    Layout.fillWidth: true
                }

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

    // Refresh,Compact button used by geometry controls
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
        border.width: 0.8

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

    // Pagination-style numeric control for geometry values
    component GeometryPager: Rectangle {
        id: pagerRoot

        property int value: 0
        property int minimum: 0
        property int maximum: 100
        readonly property bool canDecrease: enabled && value > minimum
        readonly property bool canIncrease: enabled && value < maximum
        readonly property color pagerAccentColor: Colors.alpha(Colors.bgTertiary, 0.95)
        readonly property real pagerBorderWidth: 0.8

        signal valueRequested(int requestedValue)

        Layout.preferredWidth: 124
        Layout.preferredHeight: 30
        radius: 8
        color: "transparent"
        border.color: pagerRoot.pagerAccentColor
        border.width: pagerRoot.pagerBorderWidth
        clip: true

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 31
                Layout.fillHeight: true
                opacity: pagerRoot.canDecrease ? 1 : 0.45
                color: "transparent"

                Shape {
                    id: decreaseHoverFill

                    anchors.fill: parent
                    anchors.margins: 3
                    visible: decreaseMouse.containsMouse && pagerRoot.canDecrease

                    ShapePath {
                        id: decreaseHoverPath

                        readonly property real r: Math.min(5, decreaseHoverFill.width / 2, decreaseHoverFill.height / 2)

                        fillColor: pagerRoot.pagerAccentColor
                        strokeWidth: 0
                        startX: decreaseHoverPath.r
                        startY: 0

                        PathLine {
                            x: decreaseHoverFill.width
                            y: 0
                        }
                        PathLine {
                            x: decreaseHoverFill.width
                            y: decreaseHoverFill.height
                        }
                        PathLine {
                            x: decreaseHoverPath.r
                            y: decreaseHoverFill.height
                        }
                        PathQuad {
                            x: 0
                            y: decreaseHoverFill.height - decreaseHoverPath.r
                            controlX: 0
                            controlY: decreaseHoverFill.height
                        }
                        PathLine {
                            x: 0
                            y: decreaseHoverPath.r
                        }
                        PathQuad {
                            x: decreaseHoverPath.r
                            y: 0
                            controlX: 0
                            controlY: 0
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "-"
                    color: Colors.fgPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: decreaseMouse

                    anchors.fill: parent
                    enabled: pagerRoot.canDecrease
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: pagerRoot.valueRequested(Math.max(pagerRoot.minimum, pagerRoot.value - 1))
                }
            }

            Rectangle {
                Layout.preferredWidth: pagerRoot.pagerBorderWidth
                Layout.fillHeight: true
                color: pagerRoot.pagerAccentColor
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: pagerRoot.pagerAccentColor

                Text {
                    anchors.centerIn: parent
                    text: pagerRoot.value + " px"
                    color: Colors.fgPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.DemiBold
                }
            }

            Rectangle {
                Layout.preferredWidth: pagerRoot.pagerBorderWidth
                Layout.fillHeight: true
                color: pagerRoot.pagerAccentColor
            }

            Rectangle {
                Layout.preferredWidth: 31
                Layout.fillHeight: true
                opacity: pagerRoot.canIncrease ? 1 : 0.45
                color: "transparent"

                Shape {
                    id: increaseHoverFill

                    anchors.fill: parent
                    anchors.margins: 3
                    visible: increaseMouse.containsMouse && pagerRoot.canIncrease

                    ShapePath {
                        id: increaseHoverPath

                        readonly property real r: Math.min(5, increaseHoverFill.width / 2, increaseHoverFill.height / 2)

                        fillColor: pagerRoot.pagerAccentColor
                        strokeWidth: 0
                        startX: 0
                        startY: 0

                        PathLine {
                            x: increaseHoverFill.width - increaseHoverPath.r
                            y: 0
                        }
                        PathQuad {
                            x: increaseHoverFill.width
                            y: increaseHoverPath.r
                            controlX: increaseHoverFill.width
                            controlY: 0
                        }
                        PathLine {
                            x: increaseHoverFill.width
                            y: increaseHoverFill.height - increaseHoverPath.r
                        }
                        PathQuad {
                            x: increaseHoverFill.width - increaseHoverPath.r
                            y: increaseHoverFill.height
                            controlX: increaseHoverFill.width
                            controlY: increaseHoverFill.height
                        }
                        PathLine {
                            x: 0
                            y: increaseHoverFill.height
                        }
                        PathLine {
                            x: 0
                            y: 0
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "+"
                    color: Colors.fgPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: increaseMouse

                    anchors.fill: parent
                    enabled: pagerRoot.canIncrease
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: pagerRoot.valueRequested(Math.min(pagerRoot.maximum, pagerRoot.value + 1))
                }
            }
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
        property int rowIndex: 0

        signal valueRequested(int requestedValue)

        Layout.fillWidth: true
        Layout.preferredHeight: 48
        radius: 5
        color: rowIndex % 2 === 0 ? Colors.alpha(Colors.bgTertiary, Colors.dark ? 0.14 : 0.20) : "transparent"
        border.width: 0

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

            GeometryPager {
                value: stepRoot.value
                minimum: stepRoot.minimum
                maximum: stepRoot.maximum
                onValueRequested: requestedValue => stepRoot.valueRequested(requestedValue)
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
                    Layout.preferredHeight: workspaceLayoutContent.implicitHeight + 24
                    radius: 16
                    color: card.sectionContainer
                    border.color: card.sectionBorder
                    border.width: card.sectionBorderWidth

                    // Workspace layout options content
                    GridLayout {
                        id: workspaceLayoutContent

                        anchors.fill: parent
                        anchors.margins: 12
                        columns: 2
                        columnSpacing: 14
                        rowSpacing: 4

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 300
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: "Workspace layout control"
                                color: Colors.fgPrimary
                                font.family: Typography.fontFamily
                                font.pixelSize: settings.textPixelSize
                                font.weight: Font.Bold
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Toggle the focused workspace between dwindle and scrolling."
                                color: Colors.fgSecondary
                                wrapMode: Text.WordWrap
                                font.family: Typography.fontFamily
                                font.pixelSize: settings.textPixelSize - 1
                            }
                        }

                        Controls.SegmentedTabs {
                            Layout.fillWidth: false
                            Layout.preferredWidth: 220
                            Layout.maximumWidth: 220
                            Layout.alignment: Qt.AlignTop
                            small: true
                            showIcons: false
                            model: root.workspaceLayoutOptions()
                            currentValue: Services.UiPreferences.layoutPillDisplayMode
                            onActivated: value => Services.UiPreferences.setLayoutPillDisplayMode(value)
                        }
                    }
                }

                // Persistent bar geometry controls card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: geometryContent.implicitHeight + 24
                    radius: 16
                    color: card.sectionContainer
                    border.color: card.sectionBorder
                    border.width: card.sectionBorderWidth

                    ColumnLayout {
                        id: geometryContent

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
                            rowIndex: 0
                            title: "Bar height"
                            subtitle: "Default " + Services.UiPreferences.defaultPanelHeight + " px, reserved edge height"
                            value: Services.UiPreferences.panelHeight
                            minimum: 24
                            maximum: 72
                            onValueRequested: requestedValue => Services.UiPreferences.setPanelHeight(requestedValue)
                        }

                        GeometryStepper {
                            rowIndex: 1
                            title: "Pill height"
                            subtitle: "Default " + Services.UiPreferences.defaultPillHeight + " px, capped by bar height"
                            value: Services.UiPreferences.pillHeight
                            minimum: 18
                            maximum: Services.UiPreferences.panelHeight
                            onValueRequested: requestedValue => Services.UiPreferences.setPillHeight(requestedValue)
                        }

                        GeometryStepper {
                            rowIndex: 2
                            title: "Top margin"
                            subtitle: "Default " + Services.UiPreferences.defaultTopMargin + " px, distance from screen edge"
                            value: Services.UiPreferences.topMargin
                            minimum: 0
                            maximum: 32
                            onValueRequested: requestedValue => Services.UiPreferences.setTopMargin(requestedValue)
                        }

                        GeometryStepper {
                            rowIndex: 3
                            title: "Pill radius"
                            subtitle: "Default " + Services.UiPreferences.defaultPillRadius + " px, capped at half pill height"
                            value: Services.UiPreferences.pillRadius
                            minimum: 0
                            maximum: Math.round(Services.UiPreferences.pillHeight / 2)
                            onValueRequested: requestedValue => Services.UiPreferences.setPillRadius(requestedValue)
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
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

            // SDDM login monitor selector card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: loginMonitorContent.implicitHeight + 24
                radius: 14
                color: card.sectionContainer
                border.color: card.sectionBorder
                border.width: card.sectionBorderWidth

                GridLayout {
                    id: loginMonitorContent

                    anchors.fill: parent
                    anchors.margins: 12
                    columns: 2
                    columnSpacing: 14
                    rowSpacing: 8

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 300
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: "Login monitor"
                            color: Colors.fgPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize
                            font.weight: Font.Bold
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Choose where SDDM places keyboard focus."
                            color: Colors.fgSecondary
                            wrapMode: Text.WordWrap
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize - 1
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: Services.LoginMonitor.statusText.length > 0
                            text: Services.LoginMonitor.statusText
                            color: Colors.fgSecondary
                            wrapMode: Text.WordWrap
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize - 1
                        }
                    }

                    Controls.SegmentedTabs {
                        Layout.fillWidth: false
                        Layout.preferredWidth: 210
                        Layout.maximumWidth: 210
                        Layout.alignment: Qt.AlignTop
                        small: true
                        showIcons: false
                        enabled: !Services.LoginMonitor.saving
                        model: root.loginMonitorOptions()
                        currentValue: root.loginMonitorSelection()
                        onActivated: value => Services.LoginMonitor.setSelector(value)
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
