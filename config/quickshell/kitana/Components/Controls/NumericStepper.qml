// Kitana managed Quickshell control

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "../.."
import "../../custom" as Custom

// Compact numeric stepper with rounded hover fills for decrement and increment buttons.
Rectangle {
    id: root

    Custom.Settings {
        id: settings
    }

    property real value: 0
    property real minimum: 0
    property real maximum: 100
    property real step: 1
    property int decimals: 0
    property string suffix: " px"
    property bool percentage: false
    property int controlWidth: 142
    readonly property real effectiveStep: step > 0 ? step : 1
    readonly property real epsilon: 0.000001
    readonly property bool canDecrease: enabled && value > minimum + epsilon
    readonly property bool canIncrease: enabled && value < maximum - epsilon
    readonly property color accentColor: Colors.alpha(Colors.bgTertiary, 0.95)
    readonly property real dividerWidth: 0.8

    signal valueRequested(real requestedValue)

    function clamped(nextValue: real): real {
        return Math.max(minimum, Math.min(maximum, nextValue));
    }

    function stepped(nextValue: real): real {
        const rounded = Math.round(clamped(nextValue) / effectiveStep) * effectiveStep;
        return clamped(Math.round(rounded * 1000000) / 1000000);
    }

    function displayValue(currentValue: real): string {
        if (percentage)
            return Math.round(currentValue * 100) + "%";
        return Number(currentValue).toFixed(decimals) + suffix;
    }

    Layout.preferredWidth: controlWidth
    Layout.preferredHeight: 30
    implicitWidth: controlWidth
    implicitHeight: 30
    radius: 8
    color: "transparent"
    border.color: accentColor
    border.width: dividerWidth
    border.pixelAligned: false
    antialiasing: true
    clip: true

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: decreaseButton

            Layout.preferredWidth: 31
            Layout.fillHeight: true
            opacity: root.canDecrease ? 1 : 0.45
            color: "transparent"

            Shape {
                id: decreaseHoverFill

                anchors.fill: parent
                anchors.margins: 3
                visible: decreaseMouse.containsMouse && root.canDecrease

                ShapePath {
                    id: decreaseHoverPath

                    readonly property real r: Math.min(5, decreaseHoverFill.width / 2, decreaseHoverFill.height / 2)

                    fillColor: root.accentColor
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
                enabled: root.canDecrease
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.valueRequested(root.stepped(root.value - root.effectiveStep))
            }
        }

        Rectangle {
            Layout.preferredWidth: root.dividerWidth
            Layout.fillHeight: true
            color: root.accentColor
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: root.accentColor

            Text {
                anchors.centerIn: parent
                text: root.displayValue(root.value)
                color: Colors.fgPrimary
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }
        }

        Rectangle {
            Layout.preferredWidth: root.dividerWidth
            Layout.fillHeight: true
            color: root.accentColor
        }

        Rectangle {
            id: increaseButton

            Layout.preferredWidth: 31
            Layout.fillHeight: true
            opacity: root.canIncrease ? 1 : 0.45
            color: "transparent"

            Shape {
                id: increaseHoverFill

                anchors.fill: parent
                anchors.margins: 3
                visible: increaseMouse.containsMouse && root.canIncrease

                ShapePath {
                    id: increaseHoverPath
                    readonly property real r: Math.min(5, increaseHoverFill.width / 2, increaseHoverFill.height / 2)

                    fillColor: root.accentColor
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
                enabled: root.canIncrease
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.valueRequested(root.stepped(root.value + root.effectiveStep))
            }
        }
    }
}
