// Kitana managed Quickshell control

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom
import "../../Services" as Services

// Reusable segmented selector with optional icons and compact sizing
Rectangle {
    id: root

    Custom.Settings {
        id: settings
    }

    property var model: []
    property string currentValue: ""
    property bool small: false
    property bool showIcons: true
    property bool showLabels: true
    property bool equalWidth: true
    readonly property int segmentHeight: small ? 30 : 34
    readonly property int segmentInset: small ? 4 : 5
    readonly property int segmentGap: small ? 4 : 5
    readonly property real tabRadius: Math.min(Services.UiPreferences.pillRadius, implicitHeight / 2)
    readonly property real segmentRadius: Math.max(0, Math.min(tabRadius - segmentInset, segmentHeight / 2))
    readonly property int selectedIndex: root.indexForValue(root.currentValue)

    signal activated(string value)

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
    implicitHeight: segmentHeight + segmentInset * 2
    radius: tabRadius
    color: Colors.bgTertiary
    border.color: Colors.borderFaint
    border.width: 1

    // Segmented tab strip
    Item {
        id: segmentTrack

        anchors.fill: parent
        anchors.margins: root.segmentInset

        readonly property Item selectedSegment: root.selectedIndex >= 0 && root.selectedIndex < segmentRepeater.count ? segmentRepeater.itemAt(root.selectedIndex) : null

        Rectangle {
            id: selector

            visible: segmentTrack.selectedSegment !== null
            x: visible ? segmentTrack.selectedSegment.x : 0
            y: visible ? segmentTrack.selectedSegment.y : 0
            width: visible ? segmentTrack.selectedSegment.width : 0
            height: visible ? segmentTrack.selectedSegment.height : root.segmentHeight
            radius: root.segmentRadius
            opacity: visible ? segmentTrack.selectedSegment.opacity : 0
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
            anchors.fill: parent
            spacing: root.segmentGap

            Repeater {
                id: segmentRepeater

                model: root.model

                Rectangle {
                    id: segmentRoot

                    required property var modelData
                    readonly property string segmentValue: String(root.optionField(modelData, "value", modelData))
                    readonly property string label: String(root.optionField(modelData, "label", segmentValue))
                    readonly property string iconName: String(root.optionField(modelData, "iconName", ""))
                    readonly property bool segmentEnabled: root.enabled && !!root.optionField(modelData, "enabled", true)
                    readonly property bool selected: root.currentValue === segmentValue

                    Layout.fillWidth: root.equalWidth
                    Layout.preferredWidth: root.equalWidth ? 1 : segmentContent.implicitWidth + 24
                    Layout.preferredHeight: root.segmentHeight
                    radius: root.segmentRadius
                    opacity: segmentEnabled ? 1 : 0.45
                    color: "transparent"
                    border.color: "transparent"
                    border.width: 1

                    // Segment icon and label
                    RowLayout {
                        id: segmentContent

                        anchors.centerIn: parent
                        width: Math.max(0, Math.min(implicitWidth, parent.width - 16))
                        spacing: root.small ? 5 : 7

                        Icon {
                            visible: root.showIcons && segmentRoot.iconName.length > 0
                            Layout.alignment: Qt.AlignVCenter
                            name: segmentRoot.iconName.length > 0 ? segmentRoot.iconName : Icons.defaultIcon
                            tone: segmentRoot.selected ? "accent" : "primary"
                            size: root.small ? 13 : settings.iconPixelSize
                        }

                        Text {
                            visible: root.showLabels && segmentRoot.label.length > 0
                            Layout.fillWidth: true
                            text: segmentRoot.label
                            color: segmentMouse.containsMouse && segmentRoot.segmentEnabled && !segmentRoot.selected ? Colors.fgAccent : Colors.fgPrimary
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: Typography.fontFamily
                            font.pixelSize: root.small ? settings.textPixelSize - 1 : settings.textPixelSize
                            font.weight: Font.DemiBold
                        }
                    }

                    // Segment click target
                    MouseArea {
                        id: segmentMouse

                        anchors.fill: parent
                        enabled: segmentRoot.segmentEnabled
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: if (root.currentValue !== segmentRoot.segmentValue)
                            root.activated(segmentRoot.segmentValue)
                    }
                }
            }
        }
    }
}
