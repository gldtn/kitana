// Kitana managed Quickshell service

pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property bool enabled: Quickshell.env("KITANA_POLKIT_AGENT") !== "0"
    readonly property var agent: agentLoader.item
    readonly property var flow: agent ? agent.flow : null
    readonly property bool registered: enabled && agent !== null && agent.isRegistered
    readonly property bool active: enabled && agent !== null && agent.isActive
    readonly property string statusText: !enabled ? qsTr("Native Polkit disabled")
        : agent === null ? qsTr("Native Polkit loading")
        : registered ? qsTr("Native Polkit registered")
        : qsTr("Native Polkit not registered")

    LazyLoader {
        id: agentLoader

        active: root.enabled
        source: root.enabled ? Qt.resolvedUrl("PolkitAgentHost.qml") : ""
    }
}
