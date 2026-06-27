// Kitana managed Quickshell theme preview

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "../Components/Controls" as Controls
import "../Dashboard/Components" as Dashboard
import "../System/Components" as System
import "../custom" as Custom

FloatingWindow {
    id: root

    Custom.Settings {
        id: settings
    }

    property bool panelVisible: false
    readonly property string kitanaDir: Quickshell.env("KITANA_DIR") || Quickshell.env("HOME") + "/.local/share/kitana"
    readonly property var foregroundRoles: ["fgPrimary", "fgSecondary", "fgTertiary", "fgOnPrimary", "fgAccent"]
    readonly property var backgroundRoles: ["bgPrimary", "bgSecondary", "bgTertiary", "bgOnPrimary", "bgAccent"]
    readonly property var borderRoles: ["borderDark", "borderFaint", "borderLight", "borderHeavy", "borderAccent"]
    readonly property var feedbackRoles: ["info", "success", "warning", "error", "subtleAccent", "subtlePrimary", "subtleSecondary", "subtleTertiary"]
    readonly property var overlayRoles: ["scrimPrimary", "scrimSecondary", "scrimTertiary"]
    readonly property var compositionRoles: ["inputBg", "inputFg", "inputPlaceholderFg", "inputBorder", "inputBorderFocus", "inputSelection", "inputSelectedFg", "barItemBg", "barItemBorder", "barItemFg"]
    readonly property var iconRoles: ["iconPrimary", "iconSecondary", "iconAccent", "iconBrand", "iconSubtle", "iconMuted", "iconDisabled", "iconDanger", "iconOnAccent", "iconInverse"]
    readonly property date previewNow: new Date()
    readonly property date previewCalendarMonth: new Date(previewNow.getFullYear(), previewNow.getMonth(), 1)
    readonly property var weekdayLabels: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    readonly property var iconToneSamples: [
        {
            tone: "primary",
            label: "primary"
        },
        {
            tone: "secondary",
            label: "secondary"
        },
        {
            tone: "accent",
            label: "accent"
        },
        {
            tone: "brand",
            label: "brand"
        },
        {
            tone: "subtle",
            label: "subtle"
        },
        {
            tone: "muted",
            label: "muted"
        },
        {
            tone: "disabled",
            label: "disabled"
        },
        {
            tone: "danger",
            label: "danger"
        },
        {
            tone: "onAccent",
            label: "onAccent"
        },
        {
            tone: "inverse",
            label: "inverse"
        }
    ]

    title: qsTr("Kitana Theme Preview")
    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    visible: panelVisible
    color: "transparent"
    implicitWidth: 1200
    implicitHeight: 1360
    onClosed: panelVisible = false

    function open(): void {
        panelVisible = true;
    }

    function close(): void {
        panelVisible = false;
    }

    function toggle(): void {
        panelVisible ? close() : open();
    }

    function refreshCurrentTheme(): void {
        const theme = Colors.theme && Colors.theme.slug ? Colors.theme.slug : Colors.name.toLowerCase().replace(/\s+/g, "-");
        themeRefreshProcess.exec([kitanaDir + "/bin/kitana-theme", theme]);
    }

    function roleColor(role: string): color {
        switch (role) {
        case "fgPrimary":
            return Colors.fgPrimary;
        case "fgSecondary":
            return Colors.fgSecondary;
        case "fgTertiary":
            return Colors.fgTertiary;
        case "fgOnPrimary":
            return Colors.fgOnPrimary;
        case "fgAccent":
            return Colors.fgAccent;
        case "bgPrimary":
            return Colors.bgPrimary;
        case "bgSecondary":
            return Colors.bgSecondary;
        case "bgTertiary":
            return Colors.bgTertiary;
        case "bgOnPrimary":
            return Colors.bgOnPrimary;
        case "bgAccent":
            return Colors.bgAccent;
        case "borderDark":
            return Colors.borderDark;
        case "borderLight":
            return Colors.borderLight;
        case "borderFaint":
            return Colors.borderFaint;
        case "borderHeavy":
            return Colors.borderHeavy;
        case "borderAccent":
            return Colors.borderAccent;
        case "info":
            return Colors.info;
        case "success":
            return Colors.success;
        case "warning":
            return Colors.warning;
        case "error":
            return Colors.error;
        case "scrimPrimary":
            return Colors.scrimPrimary;
        case "scrimSecondary":
            return Colors.scrimSecondary;
        case "scrimTertiary":
            return Colors.scrimTertiary;
        case "subtleAccent":
            return Colors.subtleAccent;
        case "subtlePrimary":
            return Colors.subtlePrimary;
        case "subtleSecondary":
            return Colors.subtleSecondary;
        case "subtleTertiary":
            return Colors.subtleTertiary;
        case "inputBg":
            return Colors.inputBg;
        case "inputFg":
            return Colors.inputFg;
        case "inputPlaceholderFg":
            return Colors.inputPlaceholderFg;
        case "inputBorder":
            return Colors.inputBorder;
        case "inputBorderFocus":
            return Colors.inputBorderFocus;
        case "inputSelection":
            return Colors.inputSelection;
        case "inputSelectedFg":
            return Colors.inputSelectedFg;
        case "barItemBg":
            return Colors.barItemBg;
        case "barItemBorder":
            return Colors.barItemBorder;
        case "barItemFg":
            return Colors.barItemFg;
        case "iconPrimary":
            return Colors.iconPrimary;
        case "iconSecondary":
            return Colors.iconSecondary;
        case "iconAccent":
            return Colors.iconAccent;
        case "iconBrand":
            return Colors.iconBrand;
        case "iconSubtle":
            return Colors.iconSubtle;
        case "iconMuted":
            return Colors.iconMuted;
        case "iconDisabled":
            return Colors.iconDisabled;
        case "iconDanger":
            return Colors.iconDanger;
        case "iconOnAccent":
            return Colors.iconOnAccent;
        case "iconInverse":
            return Colors.iconInverse;
        }

        return "#ff00ff";
    }

    function colorText(value: var): string {
        const text = String(value);
        return text.startsWith("#ff") && text.length === 9 ? "#" + text.slice(3) : text;
    }

    function daysInMonth(month: date): int {
        return new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate();
    }

    function previewCalendarDay(slot: int): int {
        const first = previewCalendarMonth.getDay();
        const day = slot - first + 1;
        return day > 0 && day <= daysInMonth(previewCalendarMonth) ? day : 0;
    }

    function previewIsToday(day: int): bool {
        return day === previewNow.getDate() && previewCalendarMonth.getMonth() === previewNow.getMonth() && previewCalendarMonth.getFullYear() === previewNow.getFullYear();
    }

    // Theme preview IPC command bridge
    IpcHandler {
        target: "kitana-theme-preview"

        function open(): void {
            root.open();
        }
        function close(): void {
            root.close();
        }
        function toggle(): void {
            root.toggle();
        }
    }

    // Current theme refresh command runner
    Process {
        id: themeRefreshProcess
    }

    component SectionTitle: Text {
        width: parent ? parent.width : 0
        color: Colors.fgPrimary
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize + 1
        font.weight: Font.Bold
    }

    component ColorSwatch: Rectangle {
        id: swatchRoot

        property string roleName: ""
        readonly property color previewColor: root.roleColor(roleName)

        width: 104
        height: 48
        radius: 10
        color: Colors.bgSecondary
        border.color: Colors.borderFaint
        border.width: 1

        // Color chip and role label
        Row {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 6

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 22
                height: 34
                radius: 8
                color: swatchRoot.previewColor
                border.color: Colors.borderFaint
                border.width: 1
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 28
                spacing: 2

                Text {
                    width: parent.width
                    text: swatchRoot.roleName
                    color: Colors.fgPrimary
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize - 3
                    font.weight: Font.DemiBold
                }

                Text {
                    width: parent.width
                    text: root.colorText(swatchRoot.previewColor)
                    color: Colors.fgSecondary
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize - 4
                }
            }
        }
    }

    component RoleGroup: Column {
        id: groupRoot

        property string title: ""
        property var roles: []
        property int columns: 2
        readonly property real swatchWidth: Math.floor((width - swatches.spacing * (columns - 1)) / columns)

        width: parent ? parent.width : 0
        spacing: 6

        SectionTitle {
            text: groupRoot.title
        }

        // Responsive swatch grid for one role family
        Flow {
            id: swatches

            width: parent.width
            spacing: 6

            Repeater {
                model: groupRoot.roles

                ColorSwatch {
                    required property var modelData

                    width: groupRoot.swatchWidth
                    roleName: String(modelData)
                }
            }
        }
    }

    component RoleGroupPair: Row {
        id: pairRoot

        property string leftTitle: ""
        property var leftRoles: []
        property string rightTitle: ""
        property var rightRoles: []

        width: parent ? parent.width : 0
        spacing: 10

        RoleGroup {
            width: (pairRoot.width - pairRoot.spacing) / 2
            title: pairRoot.leftTitle
            roles: pairRoot.leftRoles
        }

        RoleGroup {
            width: (pairRoot.width - pairRoot.spacing) / 2
            title: pairRoot.rightTitle
            roles: pairRoot.rightRoles
        }
    }

    component HeaderButton: Rectangle {
        id: buttonRoot

        property string label: ""

        signal clicked

        width: buttonLabel.implicitWidth + 22
        height: 28
        radius: 9
        color: buttonMouse.containsMouse ? Colors.bgTertiary : Colors.bgSecondary
        border.color: buttonMouse.containsMouse ? Colors.borderAccent : Colors.borderFaint
        border.width: 1

        Text {
            id: buttonLabel

            anchors.centerIn: parent
            text: buttonRoot.label
            color: Colors.fgPrimary
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize - 1
            font.weight: Font.DemiBold
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: buttonRoot.clicked()
        }
    }

    component IconToneSample: Item {
        id: toneRoot

        property var sample: ({})
        readonly property string toneName: String(sample.tone || "primary")
        readonly property string label: String(sample.label || toneName)

        width: 64
        height: 38

        Controls.Icon {
            id: toneIcon

            anchors.horizontalCenter: parent.horizontalCenter
            name: "theme"
            tone: toneRoot.toneName
            size: 17
        }

        Text {
            anchors.top: toneIcon.bottom
            anchors.topMargin: 0
            width: parent.width
            text: toneRoot.label
            color: Colors.fgSecondary
            horizontalAlignment: Text.AlignHCenter
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize - 5
            font.weight: Font.DemiBold
        }
    }

    component BorderDividerSample: Item {
        id: dividerRoot

        property string roleName: ""
        readonly property color dividerColor: root.roleColor(roleName)

        width: parent ? parent.width : 0
        height: 16

        Row {
            anchors.fill: parent
            spacing: 8

            Text {
                id: dividerLabel

                anchors.verticalCenter: parent.verticalCenter
                width: 88
                text: dividerRoot.roleName
                color: Colors.fgSecondary
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize - 4
                font.weight: Font.DemiBold
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - dividerLabel.width - parent.spacing
                height: 1
                radius: height / 2
                color: dividerRoot.dividerColor
            }
        }
    }

    component CalendarMiniButton: Rectangle {
        id: miniRoot

        property string iconName: ""
        property string label: ""
        property int widthOverride: 28

        width: widthOverride
        height: 24
        radius: 8
        color: Colors.bgTertiary
        border.color: Colors.borderFaint
        border.width: 1

        Controls.Icon {
            anchors.centerIn: parent
            visible: miniRoot.iconName.length > 0
            name: miniRoot.iconName.length > 0 ? miniRoot.iconName : Icons.defaultIcon
            tone: "primary"
            size: 13
        }

        Text {
            anchors.centerIn: parent
            visible: miniRoot.iconName.length === 0
            text: miniRoot.label
            color: Colors.fgPrimary
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize - 2
            font.weight: Font.DemiBold
        }
    }

    component CalendarSample: Rectangle {
        id: calendarRoot

        readonly property real cellWidth: (calendarGrid.width - calendarGrid.columnSpacing * 6) / 7

        width: parent ? parent.width : 0
        height: 286
        radius: 14
        color: Colors.bgSecondary
        border.color: Colors.borderFaint
        border.width: 0.8

        // DateTime tab monthly calendar sample
        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            Row {
                width: parent.width
                height: 24
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - calendarButtons.width - parent.spacing
                    text: Qt.formatDate(root.previewCalendarMonth, "MMMM yyyy")
                    color: Colors.fgPrimary
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize + 2
                    font.weight: Font.Bold
                }

                Row {
                    id: calendarButtons

                    anchors.verticalCenter: parent.verticalCenter
                    width: prevButton.width + todayButton.width + nextButton.width + spacing * 2
                    height: parent.height
                    spacing: 6

                    CalendarMiniButton {
                        id: prevButton

                        iconName: "ui.chevron.left"
                    }

                    CalendarMiniButton {
                        id: todayButton

                        label: qsTr("Today")
                        widthOverride: 58
                    }

                    CalendarMiniButton {
                        id: nextButton

                        iconName: "ui.chevron.right"
                    }
                }
            }

            Grid {
                id: calendarGrid

                width: parent.width
                columns: 7
                rowSpacing: 6
                columnSpacing: 6

                Repeater {
                    model: root.weekdayLabels

                    Text {
                        required property string modelData

                        width: calendarRoot.cellWidth
                        height: 18
                        text: modelData
                        color: Colors.fgAccent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                        font.weight: Font.DemiBold
                    }
                }

                Repeater {
                    model: 42

                    Rectangle {
                        id: dayCell

                        required property int index
                        readonly property int day: root.previewCalendarDay(index)
                        readonly property bool today: root.previewIsToday(day)

                        width: calendarRoot.cellWidth
                        height: 28
                        radius: 9
                        color: today ? Colors.subtleAccent : (day > 0 ? Colors.bgTertiary : "transparent")

                        Text {
                            anchors.centerIn: parent
                            text: dayCell.day > 0 ? String(dayCell.day) : ""
                            color: dayCell.today ? Colors.fgAccent : Colors.fgPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize
                            font.weight: dayCell.today ? Font.Bold : Font.Normal
                        }
                    }
                }
            }
        }
    }

    component NotificationFooterAction: Item {
        id: action

        property string iconName: Icons.defaultIcon
        property string text: ""
        property bool active: false

        width: actionRow.implicitWidth
        height: 30

        // Notification footer action icon and label
        Row {
            id: actionRow

            anchors.centerIn: parent
            spacing: 6

            Controls.Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: action.iconName
                tone: action.active || actionMouse.containsMouse ? "primary" : "muted"
                size: 14
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: action.text
                color: action.active || actionMouse.containsMouse ? Colors.fgPrimary : Colors.fgSecondary
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize + 1
                font.weight: Font.DemiBold
            }
        }

        MouseArea {
            id: actionMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }

    component ControlSurfaceSample: Rectangle {
        id: surfaceRoot

        property string label: ""
        property color surfaceColor: Colors.bgSecondary

        height: surfaceContent.implicitHeight + surfaceContent.anchors.topMargin + surfaceContent.anchors.bottomMargin
        radius: 14
        color: surfaceColor
        border.color: Colors.borderFaint
        border.width: 0.8

        QtObject {
            id: tabSampleDashboard

            property string activeTab: "themes"

            function resetPickerState(): void {
            }
            function refreshTab(): void {
            }
        }

        // Icon tones, badge, and dismiss states on one surface color
        Column {
            id: surfaceContent

            anchors.fill: parent
            anchors.margins: 9
            spacing: 6

            Row {
                width: parent.width
                height: Math.max(surfaceTitle.implicitHeight, surfaceHeaderControls.height)
                spacing: 8

                Text {
                    id: surfaceTitle

                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(0, parent.width - surfaceHeaderControls.width - parent.spacing)
                    text: surfaceRoot.label
                    color: Colors.fgPrimary
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize - 1
                    font.weight: Font.DemiBold
                }

                Row {
                    id: surfaceHeaderControls

                    width: shortcutBadge.width + dismissStates.width + spacing
                    height: Math.max(shortcutBadge.height, dismissStates.height)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Controls.ShortcutBadge {
                        id: shortcutBadge

                        width: implicitWidth
                        height: implicitHeight
                        anchors.verticalCenter: parent.verticalCenter
                        text: "PRINT"
                    }

                    Row {
                        id: dismissStates

                        width: inactiveDismiss.width + hoverDismiss.width + spacing
                        height: Math.max(inactiveDismiss.height, hoverDismiss.height)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Column {
                            id: inactiveDismiss

                            width: 50
                            spacing: 4

                            Text {
                                width: parent.width
                                text: qsTr("Inactive")
                                color: Colors.fgSecondary
                                horizontalAlignment: Text.AlignHCenter
                                font.family: Typography.fontFamily
                                font.pixelSize: settings.textPixelSize - 4
                            }

                            Controls.CloseButton {
                                width: implicitWidth
                                height: implicitHeight
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        Column {
                            id: hoverDismiss

                            width: 42
                            spacing: 4

                            Text {
                                width: parent.width
                                text: qsTr("Hover")
                                color: Colors.fgSecondary
                                horizontalAlignment: Text.AlignHCenter
                                font.family: Typography.fontFamily
                                font.pixelSize: settings.textPixelSize - 4
                            }

                            Controls.CloseButton {
                                width: implicitWidth
                                height: implicitHeight
                                anchors.horizontalCenter: parent.horizontalCenter
                                normalColor: Colors.scrimSecondary
                                hoverColor: Colors.scrimSecondary
                                normalTone: "primary"
                                hoverTone: "primary"
                            }
                        }
                    }
                }
            }

            // Actual icon tone colors on this card background
            Flow {
                id: iconToneFlow

                readonly property int columns: Math.max(1, Math.min(root.iconToneSamples.length, Math.floor((width + spacing) / 64)))
                readonly property real sampleWidth: Math.floor((width - spacing * (columns - 1)) / columns)

                width: parent.width
                spacing: 1

                Repeater {
                    model: root.iconToneSamples

                    IconToneSample {
                        required property var modelData

                        width: iconToneFlow.sampleWidth
                        sample: modelData
                    }
                }
            }

            Row {
                width: parent.width
                height: 36
                spacing: 8
                readonly property real sampleInputWidth: Math.max(120, (width - tabSample.width - spacing * 2) / 2)

                Controls.InputField {
                    width: parent.sampleInputWidth
                    height: fieldHeight
                    fieldHeight: parent.height
                    iconName: "search"
                    text: qsTr("Sample input")
                    placeholderText: qsTr("Idle input on %1").arg(surfaceRoot.label)
                }

                Controls.InputField {
                    width: parent.sampleInputWidth
                    height: fieldHeight
                    fieldHeight: parent.height
                    iconName: "search"
                    text: qsTr("Sample input")
                    placeholderText: qsTr("Focused input on %1").arg(surfaceRoot.label)
                    idleBorderColor: Colors.inputBorderFocus
                    focusBorderColor: Colors.inputBorderFocus
                }

                Dashboard.TabButton {
                    id: tabSample

                    dashboard: tabSampleDashboard
                    width: 92
                    height: parent.height
                    iconName: "theme"
                    label: qsTr("Themes")
                    tab: "themes"
                }
            }

            // Border divider colors on this surface
            Column {
                width: parent.width
                spacing: 2

                Repeater {
                    model: root.borderRoles

                    BorderDividerSample {
                        required property var modelData

                        roleName: String(modelData)
                    }
                }
            }
        }
    }

    // Draggable app-style theme preview surface
    Rectangle {
        id: card

        width: root.width
        height: root.height
        radius: 18
        color: Colors.bgPrimary
        border.color: Colors.borderFaint
        border.width: 1

        Column {
            id: cardContent

            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Drag handle and current theme metadata
            Row {
                id: previewHeader

                width: parent.width
                height: Math.max(titleColumn.implicitHeight, closeButton.height)
                spacing: 10

                Item {
                    id: titleArea

                    width: parent.width - refreshButton.width - closeButton.width - parent.spacing * 2
                    height: titleColumn.implicitHeight

                    Column {
                        id: titleColumn

                        anchors.fill: parent
                        spacing: 2

                        Text {
                            width: parent.width
                            text: qsTr("Theme Preview")
                            color: Colors.fgPrimary
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize + 5
                            font.weight: Font.Bold
                        }

                        Text {
                            width: parent.width
                            text: qsTr("%1 - %2 - live current.json").arg(Colors.name).arg(Colors.mode)
                            color: Colors.fgSecondary
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize - 1
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        cursorShape: Qt.SizeAllCursor
                        onPressed: root.startSystemMove()
                    }
                }

                HeaderButton {
                    id: refreshButton

                    anchors.verticalCenter: parent.verticalCenter
                    label: themeRefreshProcess.running ? qsTr("Refreshing") : qsTr("Refresh")
                    onClicked: root.refreshCurrentTheme()
                }

                Controls.CloseButton {
                    id: closeButton

                    width: implicitWidth
                    height: implicitHeight
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: root.close()
                }
            }

            // Scrollable preview content
            Flickable {
                id: scroll

                width: parent.width
                height: Math.max(0, parent.height - previewHeader.height - parent.spacing)
                contentWidth: width
                contentHeight: content.height
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Row {
                    id: content

                    width: scroll.width
                    height: Math.max(samplesColumn.implicitHeight, swatchesColumn.implicitHeight)
                    spacing: 16

                    // Representative shell surfaces and controls
                    Column {
                        id: samplesColumn

                        width: Math.floor((parent.width - parent.spacing) * 0.58)
                        spacing: 10

                        SectionTitle {
                            text: qsTr("Quickshell Samples")
                        }

                        Row {
                            width: parent.width
                            height: 42
                            spacing: 10

                            Rectangle {
                                width: (parent.width - parent.spacing) / 2
                                height: parent.height
                                radius: 8
                                color: Colors.barItemBg
                                border.color: Colors.barItemBorder
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 8

                                    Controls.Icon {
                                        anchors.verticalCenter: parent.verticalCenter
                                        name: "theme"
                                        tone: "primary"
                                        sizeRole: "bar"
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 116
                                        text: qsTr("Bar item")
                                        color: Colors.barItemFg
                                        elide: Text.ElideRight
                                        font.family: Typography.fontFamily
                                        font.pixelSize: settings.textPixelSize
                                        font.weight: Font.DemiBold
                                    }

                                    Controls.ShortcutBadge {
                                        width: implicitWidth
                                        height: implicitHeight
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "SUPER"
                                    }
                                }
                            }

                            Controls.InputField {
                                width: (parent.width - parent.spacing) / 2
                                height: parent.height
                                fieldHeight: parent.height
                                iconName: "search"
                                text: qsTr("sample query")
                                placeholderText: qsTr("Search theme roles")
                            }
                        }

                        Row {
                            width: parent.width
                            height: calendarSample.height
                            spacing: 10

                            CalendarSample {
                                id: calendarSample

                                width: (parent.width - parent.spacing) / 2
                            }

                            // Control samples stacked next to the calendar
                            Column {
                                width: (parent.width - parent.spacing) / 2
                                height: parent.height
                                spacing: 10

                                Row {
                                    id: quickTileSamples

                                    width: parent.width
                                    height: 64
                                    spacing: 10

                                    System.QuickTile {
                                        width: (parent.width - parent.spacing) / 2
                                        iconName: "network.wifi.high"
                                        title: qsTr("Active Tile")
                                        subtitle: qsTr("Accent icon")
                                        active: true
                                    }

                                    System.QuickTile {
                                        width: (parent.width - parent.spacing) / 2
                                        iconName: "bluetooth.on"
                                        title: qsTr("Idle Tile")
                                        subtitle: qsTr("Subtle icon")
                                        active: false
                                    }
                                }

                                // Active detail pane container
                                Rectangle {
                                    width: parent.width
                                    height: parent.height - quickTileSamples.height - parent.spacing
                                    radius: 14
                                    color: Colors.bgSecondary
                                    border.color: Colors.borderFaint
                                    border.width: 0.6
                                    clip: true

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 14
                                        spacing: 10

                                        Rectangle {
                                            width: parent.width
                                            height: 102
                                            radius: 16
                                            color: hoverHandler.hovered ? Colors.scrimTertiary : Colors.bgTertiary
                                            border.color: Colors.borderLight
                                            border.width: 0.8

                                            HoverHandler {
                                                id: hoverHandler
                                            }

                                            // Notification-style card sample
                                            Row {
                                                anchors.fill: parent
                                                anchors.margins: 12
                                                spacing: 12

                                                Rectangle {
                                                    id: notificationIcon

                                                    anchors.verticalCenter: parent.verticalCenter
                                                    width: 42
                                                    height: 42
                                                    radius: 21
                                                    color: Colors.subtleAccent

                                                    Controls.Icon {
                                                        anchors.centerIn: parent
                                                        name: "notifications.on"
                                                        tone: "accent"
                                                        size: 20
                                                    }
                                                }

                                                Column {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    width: parent.width - notificationIcon.width - dismissStates.width - parent.spacing * 2
                                                    spacing: 4

                                                    Text {
                                                        width: parent.width
                                                        text: qsTr("Notification sample")
                                                        color: Colors.fgPrimary
                                                        elide: Text.ElideRight
                                                        font.family: Typography.fontFamily
                                                        font.pixelSize: settings.textPixelSize + 1
                                                        font.weight: Font.Bold
                                                    }

                                                    Rectangle {
                                                        width: parent.width
                                                        height: 1
                                                        color: Colors.borderHeavy
                                                    }

                                                    Text {
                                                        width: parent.width
                                                        text: qsTr("Foreground, border, and tertiary surface contrast.")
                                                        color: Colors.fgSecondary
                                                        elide: Text.ElideRight
                                                        font.family: Typography.fontFamily
                                                        font.pixelSize: settings.textPixelSize - 1
                                                    }
                                                }

                                                Row {
                                                    id: dismissStates

                                                    anchors.verticalCenter: parent.verticalCenter
                                                    width: inactiveDismiss.width + activeDismiss.width + spacing
                                                    height: Math.max(inactiveDismiss.height, activeDismiss.height)
                                                    spacing: 8

                                                    Column {
                                                        id: inactiveDismiss

                                                        width: 52
                                                        spacing: 4

                                                        Text {
                                                            width: parent.width
                                                            text: qsTr("Inactive")
                                                            color: Colors.fgSecondary
                                                            horizontalAlignment: Text.AlignHCenter
                                                            font.family: Typography.fontFamily
                                                            font.pixelSize: settings.textPixelSize - 4
                                                        }

                                                        Controls.CloseButton {
                                                            width: implicitWidth
                                                            height: implicitHeight
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                        }
                                                    }

                                                    Column {
                                                        id: activeDismiss

                                                        width: 44
                                                        spacing: 4

                                                        Text {
                                                            width: parent.width
                                                            text: qsTr("Hover")
                                                            color: Colors.fgSecondary
                                                            horizontalAlignment: Text.AlignHCenter
                                                            font.family: Typography.fontFamily
                                                            font.pixelSize: settings.textPixelSize - 4
                                                        }

                                                        Controls.CloseButton {
                                                            width: implicitWidth
                                                            height: implicitHeight
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                            normalColor: Colors.scrimSecondary
                                                            hoverColor: Colors.scrimSecondary
                                                            normalTone: "primary"
                                                            hoverTone: "primary"
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            width: parent.width
                                            height: 1
                                            color: Colors.borderLight
                                        }

                                        // Notifications pane footer controls sample
                                        Row {
                                            width: parent.width
                                            height: 30
                                            spacing: 12

                                            Text {
                                                width: parent.width - silentFooterAction.width - clearFooterAction.width - parent.spacing * 2
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: qsTr("3 notifications")
                                                color: Colors.fgPrimary
                                                elide: Text.ElideRight
                                                font.family: Typography.fontFamily
                                                font.pixelSize: settings.textPixelSize + 2
                                                font.weight: Font.DemiBold
                                            }

                                            NotificationFooterAction {
                                                id: silentFooterAction

                                                iconName: "notifications.off"
                                                text: qsTr("Silent")
                                                active: true
                                            }

                                            NotificationFooterAction {
                                                id: clearFooterAction

                                                iconName: "notifications.dismiss.all"
                                                text: qsTr("Clear")
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        System.SliderRow {
                            width: parent.width
                            iconName: "brightness"
                            value: 68
                            label: "68%"
                        }

                        // Full-width background surface samples
                        Column {
                            width: parent.width
                            spacing: 10

                            ControlSurfaceSample {
                                width: parent.width
                                label: "bgPrimary"
                                surfaceColor: Colors.bgPrimary
                            }

                            ControlSurfaceSample {
                                width: parent.width
                                label: "bgSecondary"
                                surfaceColor: Colors.bgSecondary
                            }

                            ControlSurfaceSample {
                                width: parent.width
                                label: "bgTertiary"
                                surfaceColor: Colors.bgTertiary
                            }
                        }
                    }

                    // Theme role swatches
                    Column {
                        id: swatchesColumn

                        width: parent.width - samplesColumn.width - parent.spacing
                        spacing: 10

                        SectionTitle {
                            text: qsTr("Color Swatches")
                        }

                        RoleGroup {
                            title: qsTr("Foreground")
                            columns: 3
                            roles: root.foregroundRoles
                        }

                        RoleGroup {
                            title: qsTr("Background")
                            columns: 3
                            roles: root.backgroundRoles
                        }

                        RoleGroup {
                            title: qsTr("Border")
                            columns: 3
                            roles: root.borderRoles
                        }

                        RoleGroup {
                            title: qsTr("Overlay")
                            columns: 3
                            roles: root.overlayRoles
                        }

                        RoleGroup {
                            title: qsTr("Feedback And Subtle")
                            columns: 3
                            roles: root.feedbackRoles
                        }

                        RoleGroup {
                            title: qsTr("QML Composition")
                            columns: 3
                            roles: root.compositionRoles
                        }

                        RoleGroup {
                            title: qsTr("Icon Tones")
                            columns: 3
                            roles: root.iconRoles
                        }
                    }
                }
            }
        }
    }
}
