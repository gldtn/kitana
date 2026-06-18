// Kitana managed Quickshell system component

import QtQuick
import "../../Components/Controls" as Controls

Controls.Icon {
    id: root

    signal clicked

    tone: "primary"
    sizeRole: "bar"
    size: 15

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
