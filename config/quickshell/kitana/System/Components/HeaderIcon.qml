// Kitana managed Quickshell system component

import QtQuick
import "../.."
import "../../custom" as Custom

Text {
    id: root

    Custom.Settings { id: settings }

    signal clicked

    color: Colors.foreground
    font.family: Typography.iconFontFamily
    font.pixelSize: 15
    font.variableAxes: {
        "FILL": Typography.iconFill,
        "wght": Typography.iconWeight,
        "GRAD": Typography.iconGrade,
        "opsz": Typography.iconOpticalSize
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
