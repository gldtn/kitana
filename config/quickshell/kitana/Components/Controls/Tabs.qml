// Kitana managed Quickshell control

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom
import "../../Services" as Services

// Flux-inspired tabs with default, segmented, pill, and vertical icon layouts.
Item {
    id: root

    Custom.Settings {
        id: settings
    }

    property var model: []
    property string currentValue: ""
    property string variant: "default"
    property string iconPosition: "leading"
    property bool small: false
    property bool showIcons: true
    property bool showLabels: true
    property bool equalWidth: true
    readonly property string resolvedVariant: normalizedVariant()
    readonly property bool defaultTabs: resolvedVariant === "default"
    readonly property bool segmented: resolvedVariant === "segmented"
    readonly property bool pills: resolvedVariant === "pills"
    readonly property bool iconTop: iconPosition === "top"
    readonly property int tabHeight: iconTop ? (small ? 48 : 56) : (small ? 30 : 38)
    readonly property int trackInset: segmented ? (small ? 4 : 5) : 0
    readonly property int tabGap: segmented ? (small ? 4 : 5) : (pills ? (small ? 4 : 6) : 2)
    readonly property int horizontalPadding: iconTop ? 12 : (small ? 11 : 14)
    readonly property int minimumTabWidth: iconTop ? 74 : 0
    readonly property real containerRadius: Math.min(Services.UiPreferences.pillRadius, implicitHeight / 2)
    readonly property real tabRadius: segmented ? Math.max(0, Math.min(containerRadius - trackInset, tabHeight / 2)) : (pills ? Math.min(Services.UiPreferences.pillRadius, tabHeight / 2) : 0)
    readonly property int selectedIndex: root.indexForValue(root.currentValue)

    signal activated(string value)

    function normalizedVariant(): string {
        if (variant === "segmented" || variant === "pills")
            return variant;
        return "default";
    }

    function optionField(option: var, field: string, fallback: var): var {
        if (option && typeof option === "object" && option[field] !== undefined && option[field] !== null)
            return option[field];
        return fallback;
    }

    function indexForValue(value: string): int {
        if (!root.model || root.model.length === undefined)
            return -1;

        for (let i = 0; i < root.model.length; i++) {
            const option = root.model[i];
            if (String(root.optionField(option, "value", option)) === value)
                return i;
        }

        return -1;
    }

    Layout.fillWidth: true
    Layout.preferredHeight: implicitHeight
    implicitWidth: tabRow.implicitWidth + trackInset * 2
    implicitHeight: tabHeight + trackInset * 2

    Rectangle {
        anchors.fill: parent
        visible: root.segmented
        radius: root.containerRadius
        color: Colors.bgTertiary
        border.color: Colors.borderFaint
        border.width: 1
    }

    Rectangle {
        visible: root.defaultTabs
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Colors.borderFaint
    }

    // Tab strip track and optional segmented selector.
    Item {
        id: tabTrack

        anchors.fill: parent
        anchors.margins: root.trackInset

        readonly property Item selectedTab: root.selectedIndex >= 0 && root.selectedIndex < tabRepeater.count ? tabRepeater.itemAt(root.selectedIndex) : null

        Rectangle {
            id: selector

            visible: root.segmented && tabTrack.selectedTab !== null
            x: visible ? tabTrack.selectedTab.x : 0
            y: visible ? tabTrack.selectedTab.y : 0
            width: visible ? tabTrack.selectedTab.width : 0
            height: visible ? tabTrack.selectedTab.height : root.tabHeight
            radius: root.tabRadius
            opacity: visible ? tabTrack.selectedTab.opacity : 0
            color: Colors.subtleAccent
            border.color: Colors.borderAccent
            border.width: 1

            Behavior on x {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
        }

        RowLayout {
            id: tabRow

            anchors.fill: parent
            spacing: root.tabGap

            Repeater {
                id: tabRepeater

                model: root.model

                Rectangle {
                    id: tabRoot

                    required property var modelData
                    readonly property string tabValue: String(root.optionField(modelData, "value", modelData))
                    readonly property string label: String(root.optionField(modelData, "label", tabValue))
                    readonly property string iconName: String(root.optionField(modelData, "iconName", ""))
                    readonly property string trailingIconName: String(root.optionField(modelData, "trailingIconName", ""))
                    readonly property bool tabEnabled: root.enabled && !!root.optionField(modelData, "enabled", true)
                    readonly property bool selected: root.currentValue === tabValue
                    readonly property bool accent: !!root.optionField(modelData, "accent", false)
                    readonly property bool hovered: tabMouse.containsMouse && tabEnabled
                    readonly property color textColor: selected || accent ? Colors.fgAccent : (hovered ? Colors.fgPrimary : Colors.fgSecondary)
                    readonly property string iconTone: selected || accent ? "accent" : (hovered ? "primary" : "secondary")
                    readonly property real preferredContentWidth: root.iconTop ? Math.max(topIcon.implicitWidth, topLabel.implicitWidth) : leadingContent.implicitWidth
                    readonly property real underlineWidth: Math.max(24, Math.min(width - 12, root.iconTop ? topLabel.implicitWidth + 8 : preferredContentWidth + 4))

                    Layout.fillWidth: root.equalWidth
                    Layout.preferredWidth: root.equalWidth ? 1 : Math.max(root.minimumTabWidth, preferredContentWidth + root.horizontalPadding * 2)
                    Layout.preferredHeight: root.tabHeight
                    radius: root.tabRadius
                    opacity: tabEnabled ? 1 : 0.45
                    color: root.pills && selected ? Colors.subtleAccent : (root.pills && hovered ? Colors.bgTertiary : "transparent")
                    border.color: root.pills && selected ? Colors.borderAccent : "transparent"
                    border.width: root.pills && selected ? 1 : 0

                    Rectangle {
                        visible: root.defaultTabs && tabRoot.selected
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        width: tabRoot.underlineWidth
                        height: 2
                        radius: height / 2
                        color: Colors.fgAccent
                    }

                    // Leading-icon tab content.
                    RowLayout {
                        id: leadingContent

                        visible: !root.iconTop
                        anchors.centerIn: parent
                        width: Math.max(0, Math.min(implicitWidth, parent.width - root.horizontalPadding * 2))
                        spacing: root.small ? 5 : 7

                        Icon {
                            visible: root.showIcons && tabRoot.iconName.length > 0
                            Layout.alignment: Qt.AlignVCenter
                            name: tabRoot.iconName.length > 0 ? tabRoot.iconName : Icons.defaultIcon
                            tone: tabRoot.iconTone
                            size: root.small ? 13 : settings.iconPixelSize
                        }

                        Text {
                            visible: root.showLabels && tabRoot.label.length > 0
                            Layout.fillWidth: true
                            text: tabRoot.label
                            color: tabRoot.textColor
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: Typography.fontFamily
                            font.pixelSize: root.small ? settings.textPixelSize - 1 : settings.textPixelSize
                            font.weight: tabRoot.selected ? Font.Bold : Font.DemiBold
                        }

                        Icon {
                            visible: root.showIcons && tabRoot.trailingIconName.length > 0
                            Layout.alignment: Qt.AlignVCenter
                            name: tabRoot.trailingIconName.length > 0 ? tabRoot.trailingIconName : Icons.defaultIcon
                            tone: tabRoot.iconTone
                            size: root.small ? 13 : settings.iconPixelSize
                        }
                    }

                    // Vertical icon-over-label tab content.
                    Column {
                        id: topContent

                        visible: root.iconTop
                        anchors.centerIn: parent
                        width: Math.max(0, parent.width - root.horizontalPadding * 2)
                        spacing: root.small ? 2 : 4

                        Icon {
                            id: topIcon

                            visible: root.showIcons && tabRoot.iconName.length > 0
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: tabRoot.iconName.length > 0 ? tabRoot.iconName : Icons.defaultIcon
                            tone: tabRoot.iconTone
                            size: root.small ? 15 : 18
                        }

                        Text {
                            id: topLabel

                            visible: root.showLabels && tabRoot.label.length > 0
                            width: parent.width
                            text: tabRoot.label
                            color: tabRoot.textColor
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: Typography.fontFamily
                            font.pixelSize: root.small ? settings.textPixelSize - 2 : settings.textPixelSize - 1
                            font.weight: tabRoot.selected ? Font.Bold : Font.DemiBold
                        }
                    }

                    // Tab click target.
                    MouseArea {
                        id: tabMouse

                        anchors.fill: parent
                        enabled: tabRoot.tabEnabled
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: if (root.currentValue !== tabRoot.tabValue)
                            root.activated(tabRoot.tabValue)
                    }
                }
            }
        }
    }
}
