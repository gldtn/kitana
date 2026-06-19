// Kitana managed Quickshell launcher

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets as QW
import ".."
import "../Components/Controls" as Controls
import "../custom" as Custom
import "../Services" as Services

// qmllint disable uncreatable-type
PanelWindow {
    id: root
    // qmllint enable uncreatable-type

    Custom.Settings { id: settings }

    visible: panelVisible
    focusable: true
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-blurred-panel"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    property string query: ""
    property var results: []
    property bool panelVisible: false
    property int selectedIndex: 0
    property string statusText: ""
    readonly property int cardWidth: Math.min(720, width - 96)
    readonly property int cardHeight: Math.min(620, height - 120)
    property alias backdropItem: backdrop

    function refreshResults(): void {
        results = Services.AppSearchService.search(query);
        selectedIndex = results.length > 0 ? Math.min(selectedIndex, results.length - 1) : -1;
    }

    function moveSelection(delta: int): void {
        if (results.length === 0)
            return;
        selectedIndex = Math.max(0, Math.min(results.length - 1, selectedIndex + delta));
        listView.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function shellQuote(value): string {
        return "'" + (value || "").toString().replace(/'/g, "'\\''") + "'";
    }

    function luaQuote(value): string {
        return "'" + (value || "").toString().replace(/\\/g, "\\\\").replace(/'/g, "\\'") + "'";
    }

    function currentWorkspaceId(): int {
        const workspace = Hyprland.focusedWorkspace || Hyprland.workspaces.values.find(item => item.active);
        return workspace && workspace.id > 0 ? workspace.id : 1;
    }

    function commandString(command, workingDirectory): string {
        if (!command || command.length === 0)
            return "";

        const parts = [];
        for (const arg of command)
            parts.push(shellQuote(arg));

        const commandLine = parts.join(" ");
        if (workingDirectory && workingDirectory.length > 0)
            return "cd " + shellQuote(workingDirectory) + " && exec " + commandLine;
        return commandLine;
    }

    function launchCommandOnWorkspace(command, workingDirectory, workspaceId: int): bool {
        const launch = commandString(command, workingDirectory || "");
        if (launch.length === 0)
            return false;

        if (Hyprland.usingLua) {
            Hyprland.dispatch("hl.dsp.focus({ workspace = " + workspaceId + " })");
            Hyprland.dispatch("hl.dsp.exec_cmd(" + luaQuote(launch) + ")");
        } else {
            Hyprland.dispatch("exec [workspace " + workspaceId + "] " + launch);
        }
        return true;
    }

    function launchItem(item): void {
        if (!item)
            return;

        const workspaceId = currentWorkspaceId();
        close();
        Services.AppSearchService.recordLaunch(item);

        if (item.type === "calculator") {
            Quickshell.execDetached(["wl-copy", item.value || ""]);
            return;
        }

        if (item.type === "session") {
            Quickshell.execDetached(item.command || []);
            return;
        }

        if (item.type === "action" && item.action) {
            if (item.action.command && launchCommandOnWorkspace(item.action.command, item.app ? item.app.workingDirectory : "", workspaceId))
                return;
            if (item.action.command)
                Quickshell.execDetached({ command: item.action.command, workingDirectory: item.app ? item.app.workingDirectory : "" });
            else if (typeof item.action.execute === "function")
                item.action.execute();
            return;
        }

        const app = item.app || item;

        if (app.command && launchCommandOnWorkspace(app.command, app.workingDirectory || "", workspaceId))
            return;
        if (typeof app.launch === "function") {
            app.launch();
            return;
        }

        const id = (app.id || "").replace(/\.desktop$/, "");
        if (id.length > 0)
            Quickshell.execDetached(["gtk-launch", id]);
    }

    function launchCurrent(): void {
        if (selectedIndex >= 0 && selectedIndex < results.length)
            launchItem(results[selectedIndex]);
    }

    function iconSource(item): string {
        const icon = item && item.icon ? item.icon : "application-x-executable";
        if (icon.startsWith("/") || icon.startsWith("file://"))
            return icon.startsWith("file://") ? icon : "file://" + icon;
        return Quickshell.iconPath(icon, true) || "";
    }

    function open(): void {
        Services.AppSearchService.refresh();
        panelVisible = true;
        query = "";
        statusText = "";
        selectedIndex = 0;
        refreshResults();
        Qt.callLater(() => search.forceActiveFocus());
    }

    function close(): void {
        panelVisible = false;
    }

    function toggle(): void {
        if (panelVisible)
            close();
        else
            open();
    }

    // Launcher IPC command bridge
    IpcHandler {
        target: "kitana-launcher"

        function open(): void { root.open(); }
        function close(): void { root.close(); }
        function toggle(): void { root.toggle(); }
    }

    // Refresh visible results when app cache changes
    Connections {
        target: Services.AppSearchService
        function onApplicationsChanged(): void {
            if (root.visible)
                root.refreshResults();
        }
    }

    // Full-screen launcher overlay and key handler
    FocusScope {
        id: overlay
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: event => {
            const text = event.text.toLowerCase();
            if (event.key === Qt.Key_Escape) {
                root.close();
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.launchCurrent();
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                root.moveSelection(1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                root.moveSelection(-1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Home) {
                root.selectedIndex = root.results.length > 0 ? 0 : -1;
                if (root.selectedIndex >= 0)
                    listView.positionViewAtIndex(root.selectedIndex, ListView.Beginning);
                event.accepted = true;
            } else if (event.key === Qt.Key_End) {
                root.selectedIndex = root.results.length > 0 ? root.results.length - 1 : -1;
                if (root.selectedIndex >= 0)
                    listView.positionViewAtIndex(root.selectedIndex, ListView.End);
                event.accepted = true;
            }
        }

        // Blurred launcher backdrop
        Controls.BlurredBackdrop {
            id: backdrop

            anchors.fill: parent
        }

        // Full-screen close catcher
        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }

        // Main launcher card
        Rectangle {
            width: root.cardWidth
            height: root.cardHeight
            anchors.centerIn: parent
            radius: 18
            color: Colors.bgPrimary
            border.color: Colors.borderFaint
            border.width: 1

            // Launcher content stack
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                // Launcher title row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: "Launch"
                        color: Colors.fgPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                    }

                    Controls.CloseButton {
                        Layout.alignment: Qt.AlignVCenter
                        onClicked: root.close()
                    }
                }

                // Search input frame
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    radius: 12
                    color: Colors.bgTertiary
                    border.color: search.activeFocus ? Colors.borderAccent : Colors.borderFaint
                    border.width: 1

                    // Search icon and input row
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 10

                        // Search icon
                        Controls.Icon {
                            name: "search"
                            tone: "muted"
                            size: 18
                        }

                        // Launcher search input
                        TextInput {
                            id: search
                            Layout.fillWidth: true
                            text: root.query
                            focus: true
                            color: Colors.fgPrimary
                            selectionColor: Colors.subtleAccent
                            selectedTextColor: Colors.fgPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: 18
                            clip: true
                            verticalAlignment: TextInput.AlignVCenter
                            activeFocusOnTab: true

                            onTextChanged: {
                                root.query = text;
                                root.selectedIndex = 0;
                                root.refreshResults();
                            }

                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Escape) {
                                    root.close();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    root.launchCurrent();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Down) {
                                    root.moveSelection(1);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Up) {
                                    root.moveSelection(-1);
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                }

                // Results list area
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Search results list
                    ListView {
                        id: listView
                        anchors.fill: parent
                        clip: true
                        spacing: 8
                        model: root.results
                        currentIndex: root.selectedIndex

                        // One launcher result row
                        delegate: Rectangle {
                            id: resultDelegate

                            required property int index
                            required property var modelData

                            width: listView.width
                            height: 58
                            radius: 12
                            color: resultDelegate.index === root.selectedIndex ? Colors.subtleAccent : (mouse.containsMouse ? Colors.bgTertiary : "transparent")
                            border.color: resultDelegate.index === root.selectedIndex ? Colors.borderAccent : "transparent"
                            border.width: 1

                            // Result row click target
                            MouseArea {
                                id: mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: root.selectedIndex = resultDelegate.index
                                onClicked: root.launchItem(resultDelegate.modelData)
                            }

                            // Result row content
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 12

                                // App icon slot
                                Item {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34

                                    readonly property string resolvedIcon: root.iconSource(resultDelegate.modelData)

                                    // Resolved desktop icon image
                                    QW.IconImage {
                                        id: appIcon
                                        anchors.fill: parent
                                        implicitSize: 34
                                        source: parent.resolvedIcon
                                        visible: parent.resolvedIcon.length > 0 && status === Image.Ready
                                        asynchronous: true
                                        mipmap: true
                                    }

                                    // Fallback app icon badge
                                    Rectangle {
                                        anchors.fill: parent
                                        visible: parent.resolvedIcon.length === 0 || !appIcon.visible
                                        radius: 9
                                        color: Colors.bgTertiary

                                        Controls.Icon {
                                            visible: !!resultDelegate.modelData.fallbackIconName && resultDelegate.modelData.fallbackIconName.length > 0
                                            anchors.centerIn: parent
                                            name: resultDelegate.modelData.fallbackIconName || Icons.defaultIcon
                                            tone: "accent"
                                            size: 15
                                        }

                                        Text {
                                            visible: !resultDelegate.modelData.fallbackIconName || resultDelegate.modelData.fallbackIconName.length === 0
                                            anchors.centerIn: parent
                                            text: (resultDelegate.modelData.name || "A").charAt(0).toUpperCase()
                                            color: Colors.fgAccent
                                            font.family: Typography.fontFamily
                                            font.pixelSize: 15
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                // Result title and subtitle
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        Layout.fillWidth: true
                                        text: resultDelegate.modelData.name || "Application"
                                        color: Colors.fgPrimary
                                        elide: Text.ElideRight
                                        font.family: Typography.fontFamily
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: resultDelegate.modelData.subtitle || ""
                                        color: Colors.fgSecondary
                                        elide: Text.ElideRight
                                        font.family: Typography.fontFamily
                                        font.pixelSize: 12
                                    }
                                }

                                // Selected result action hint
                                Text {
                                    visible: resultDelegate.index === root.selectedIndex
                                    text: resultDelegate.modelData.hint || "Enter"
                                    color: Colors.fgAccent
                                    font.family: Typography.fontFamily
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }

                    // Empty results message
                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: root.results.length === 0
                        spacing: 10

                        Controls.Icon {
                            Layout.alignment: Qt.AlignHCenter
                            name: "search"
                            tone: "muted"
                            size: 30
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "No results found"
                            color: Colors.fgSecondary
                            horizontalAlignment: Text.AlignHCenter
                            font.family: Typography.fontFamily
                            font.pixelSize: 14
                        }
                    }
                }

                // Footer divider
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Colors.borderFaint
                    opacity: 0.55
                }

                // Launcher keyboard hints
                Controls.KeyHintBar {
                    hints: "↑/↓ move · Enter run/copy · =2+2 calculator · lock/reboot actions · Esc close"
                }
            }
        }
    }
}
