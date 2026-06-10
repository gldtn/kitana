// Kitana managed Quickshell system pane

import QtQuick
import "../.."
import "../Components"
import "../../custom" as Custom

Column {
    id: root

    Custom.Settings { id: settings }

    property var panel: null

    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    spacing: 10

    Text {
        width: parent.width
        text: "Session"
        color: Colors.foreground
        font.family: Typography.fontFamily
        font.pixelSize: 14
        font.weight: Font.Bold
    }

    DetailRow { icon: Icons.lock; title: "Lock"; subtitle: "Lock this session"; onClicked: if (root.panel) root.panel.lockSession() }
    DetailRow { icon: Icons.logout; title: "Log out"; subtitle: "Confirm before ending session"; onClicked: if (root.panel) root.panel.ask("logout", "Log out?") }
    DetailRow { icon: Icons.restart; title: "Restart"; subtitle: "Confirm before reboot"; onClicked: if (root.panel) root.panel.ask("restart", "Restart?") }
    DetailRow { icon: Icons.shutdown; title: "Shut down"; subtitle: "Confirm before poweroff"; onClicked: if (root.panel) root.panel.ask("shutdown", "Shut down?") }
}
