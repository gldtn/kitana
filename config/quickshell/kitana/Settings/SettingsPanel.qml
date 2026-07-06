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

    function settingsSections(): var {
        return [
            {
                heading: "",
                items: [
                    {
                        value: "bar",
                        label: "Bar",
                        iconName: "workspace.layout"
                    },
                    {
                        value: "system",
                        label: "System",
                        iconName: "settings"
                    }
                ]
            }
        ];
    }

    function activeTabLabel(): string {
        if (activeTab === "system")
            return "System";
        return "Bar";
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

        width: Math.min(940, parent.width - 72)
        height: Math.min(560, parent.height - 120)
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

        // Settings sidebar and active content area.
        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 14

            Controls.NavListSidebar {
                Layout.preferredWidth: 218
                Layout.fillHeight: true
                title: "Settings"
                model: root.settingsSections()
                currentValue: root.activeTab
                onActivated: value => root.activeTab = value
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: Colors.borderFaint
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: root.activeTabLabel()
                        color: Colors.fgPrimary
                        elide: Text.ElideRight
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize + 4
                        font.weight: Font.Black
                    }

                    Controls.CloseButton {
                        Layout.alignment: Qt.AlignVCenter
                        onClicked: root.close()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Colors.borderFaint
                }

                // Active settings page loader.
                Loader {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    sourceComponent: root.activeTab === "system" ? systemTab : barTab
                }
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
        border.pixelAligned: false
        antialiasing: true

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

    // Numeric preference row backed by the shared rounded stepper control.
    component NumericPreferenceRow: Rectangle {
        id: rowRoot

        property string title: ""
        property string subtitle: ""
        property real value: 0
        property real minimum: 0
        property real maximum: 100
        property real step: 1
        property int decimals: 0
        property int rowIndex: 0
        property string suffix: " px"
        property bool percentage: false
        property int controlWidth: percentage || decimals > 0 ? 142 : 124

        signal valueRequested(real requestedValue)

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

            Controls.NumericStepper {
                value: rowRoot.value
                minimum: rowRoot.minimum
                maximum: rowRoot.maximum
                step: rowRoot.step
                decimals: rowRoot.decimals
                suffix: rowRoot.suffix
                percentage: rowRoot.percentage
                controlWidth: rowRoot.controlWidth
                onValueRequested: requestedValue => rowRoot.valueRequested(requestedValue)
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

                // Persistent bar appearance controls card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: appearanceContent.implicitHeight + 24
                    radius: 16
                    color: card.sectionContainer
                    border.color: card.sectionBorder
                    border.width: card.sectionBorderWidth
                    border.pixelAligned: false
                    antialiasing: true

                    ColumnLayout {
                        id: appearanceContent

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
                                    text: "Bar appearance"
                                    color: Colors.fgPrimary
                                    font.family: Typography.fontFamily
                                    font.pixelSize: settings.textPixelSize
                                    font.weight: Font.Bold
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: "Stored live; controls main bar pills and the collapsed dashboard island."
                                    color: Colors.fgSecondary
                                    elide: Text.ElideRight
                                    font.family: Typography.fontFamily
                                    font.pixelSize: settings.textPixelSize - 1
                                }
                            }

                            GeometryActionButton {
                                label: "Reset"
                                onClicked: Services.UiPreferences.resetBarAppearance()
                            }
                        }

                        NumericPreferenceRow {
                            rowIndex: 0
                            title: "Pill opacity"
                            subtitle: "Default " + Math.round(Services.UiPreferences.defaultBarItemBgOpacity * 100) + "%, applied from Colors.barItemBg"
                            value: Services.UiPreferences.barItemBgOpacity
                            minimum: 0.35
                            maximum: 1
                            step: 0.05
                            percentage: true
                            onValueRequested: requestedValue => Services.UiPreferences.setBarItemBgOpacity(requestedValue)
                        }

                        NumericPreferenceRow {
                            rowIndex: 1
                            title: "Border width"
                            subtitle: "Default " + Services.UiPreferences.defaultBarBorderWidth.toFixed(2) + " px, accepts fractional values"
                            value: Services.UiPreferences.barBorderWidth
                            minimum: 0
                            maximum: 2
                            step: 0.05
                            decimals: 2
                            suffix: " px"
                            onValueRequested: requestedValue => Services.UiPreferences.setBarBorderWidth(requestedValue)
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
                    border.pixelAligned: false
                    antialiasing: true

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

                        NumericPreferenceRow {
                            rowIndex: 0
                            title: "Bar height"
                            subtitle: "Default " + Services.UiPreferences.defaultPanelHeight + " px, reserved edge height"
                            value: Services.UiPreferences.panelHeight
                            minimum: 24
                            maximum: 72
                            onValueRequested: requestedValue => Services.UiPreferences.setPanelHeight(Math.round(requestedValue))
                        }

                        NumericPreferenceRow {
                            rowIndex: 1
                            title: "Pill height"
                            subtitle: "Default " + Services.UiPreferences.defaultPillHeight + " px, capped by bar height"
                            value: Services.UiPreferences.pillHeight
                            minimum: 18
                            maximum: Services.UiPreferences.panelHeight
                            onValueRequested: requestedValue => Services.UiPreferences.setPillHeight(Math.round(requestedValue))
                        }

                        NumericPreferenceRow {
                            rowIndex: 2
                            title: "Top margin"
                            subtitle: "Default " + Services.UiPreferences.defaultTopMargin + " px, distance from screen edge"
                            value: Services.UiPreferences.topMargin
                            minimum: 0
                            maximum: 32
                            onValueRequested: requestedValue => Services.UiPreferences.setTopMargin(Math.round(requestedValue))
                        }

                        NumericPreferenceRow {
                            rowIndex: 3
                            title: "Pill radius"
                            subtitle: "Default " + Services.UiPreferences.defaultPillRadius + " px, capped at half pill height"
                            value: Services.UiPreferences.pillRadius
                            minimum: 0
                            maximum: Math.round(Services.UiPreferences.pillHeight / 2)
                            onValueRequested: requestedValue => Services.UiPreferences.setPillRadius(Math.round(requestedValue))
                        }
                    }
                }

                // Workspace layout options card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: workspaceLayoutContent.implicitHeight + 24
                    radius: 16
                    color: card.sectionContainer
                    border.color: card.sectionBorder
                    border.width: card.sectionBorderWidth
                    border.pixelAligned: false
                    antialiasing: true

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

                        Controls.Tabs {
                            Layout.fillWidth: false
                            Layout.preferredWidth: 220
                            Layout.maximumWidth: 220
                            Layout.alignment: Qt.AlignTop
                            variant: "segmented"
                            small: true
                            showIcons: false
                            model: root.workspaceLayoutOptions()
                            currentValue: Services.UiPreferences.layoutPillDisplayMode
                            onActivated: value => Services.UiPreferences.setLayoutPillDisplayMode(value)
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

            // SDDM login monitor selector card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: loginMonitorContent.implicitHeight + 24
                radius: 14
                color: card.sectionContainer
                border.color: card.sectionBorder
                border.width: card.sectionBorderWidth
                border.pixelAligned: false
                antialiasing: true

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

                    Controls.Tabs {
                        Layout.fillWidth: false
                        Layout.preferredWidth: 210
                        Layout.maximumWidth: 210
                        Layout.alignment: Qt.AlignTop
                        variant: "segmented"
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
