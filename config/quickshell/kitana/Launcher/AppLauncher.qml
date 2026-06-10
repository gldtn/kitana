// Kitana managed Quickshell launcher

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

PanelWindow {
    id: root

    Custom.Settings { id: settings }

    visible: false
    focusable: true
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Overlay
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
    property int selectedIndex: 0
    property string statusText: ""
    property int cardWidth: Math.min(720, width - 96)
    property int cardHeight: Math.min(620, height - 120)

    function refreshResults(): void {
        results = Services.AppSearchService.search(query);
        selectedIndex = results.length > 0 ? Math.min(selectedIndex, results.length - 1) : -1;
        listView.currentIndex = selectedIndex;
    }

    function moveSelection(delta: int): void {
        if (results.length === 0)
            return;
        selectedIndex = Math.max(0, Math.min(results.length - 1, selectedIndex + delta));
        listView.currentIndex = selectedIndex;
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
        visible = true;
        query = "";
        search.text = "";
        statusText = "";
        selectedIndex = 0;
        refreshResults();
        Qt.callLater(() => search.forceActiveFocus());
    }

    function close(): void {
        visible = false;
    }

    function toggle(): void {
        if (visible)
            close();
        else
            open();
    }

    IpcHandler {
        target: "kitana-launcher"

        function open(): void { root.open(); }
        function close(): void { root.close(); }
        function toggle(): void { root.toggle(); }
    }

    Connections {
        target: Services.AppSearchService
        function onApplicationsChanged(): void {
            if (root.visible)
                root.refreshResults();
        }
    }

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
                root.selectedIndex = 0;
                listView.currentIndex = root.selectedIndex;
                listView.positionViewAtIndex(root.selectedIndex, ListView.Beginning);
                event.accepted = true;
            } else if (event.key === Qt.Key_End) {
                root.selectedIndex = Math.max(0, root.results.length - 1);
                listView.currentIndex = root.selectedIndex;
                listView.positionViewAtIndex(root.selectedIndex, ListView.End);
                event.accepted = true;
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Colors.scrimSoft
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }

        Rectangle {
            width: root.cardWidth
            height: root.cardHeight
            anchors.centerIn: parent
            radius: 18
            color: Colors.panelBackground
            border.color: Colors.panelBorder
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                Text {
                    Layout.fillWidth: true
                    text: "Launch"
                    color: Colors.foreground
                    font.family: Typography.fontFamily
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 52
                    radius: 12
                    color: Colors.panelInputBackground
                    border.color: search.activeFocus ? Colors.panelInputBorderActive : Colors.panelInputBorder
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 10

                        Controls.Icon {
                            icon: Icons.appSearch
                            color: Colors.muted
                            size: 18
                        }

                        TextInput {
                            id: search
                            Layout.fillWidth: true
                            focus: true
                            color: Colors.panelInputForeground
                            selectionColor: Colors.accentBackground
                            selectedTextColor: Colors.foreground
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

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ListView {
                        id: listView
                        anchors.fill: parent
                        clip: true
                        spacing: 8
                        model: root.results
                        currentIndex: root.selectedIndex

                        delegate: Rectangle {
                            required property int index
                            required property var modelData

                            width: listView.width
                            height: 58
                            radius: 12
                            color: index === root.selectedIndex ? Colors.surfaceHighlight : (mouse.containsMouse ? Colors.surfaceHover : "transparent")
                            border.color: index === root.selectedIndex ? Colors.panelBorderStrong : "transparent"
                            border.width: 1

                            MouseArea {
                                id: mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: root.selectedIndex = index
                                onClicked: root.launchItem(modelData)
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 12

                                Item {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34

                                    readonly property string resolvedIcon: root.iconSource(modelData)

                                    QW.IconImage {
                                        id: appIcon
                                        anchors.fill: parent
                                        implicitSize: 34
                                        source: parent.resolvedIcon
                                        visible: parent.resolvedIcon.length > 0 && status === Image.Ready
                                        asynchronous: true
                                        mipmap: true
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        visible: parent.resolvedIcon.length === 0 || !appIcon.visible
                                        radius: 9
                                        color: Colors.surfaceHover

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.fallbackIcon || (modelData.name || "A").charAt(0).toUpperCase()
                                            color: Colors.accent
                                            font.family: modelData.fallbackIcon ? Typography.iconFontFamily : Typography.fontFamily
                                            font.pixelSize: 15
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name || "Application"
                                        color: Colors.foreground
                                        elide: Text.ElideRight
                                        font.family: Typography.fontFamily
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.subtitle || ""
                                        color: Colors.muted
                                        elide: Text.ElideRight
                                        font.family: Typography.fontFamily
                                        font.pixelSize: 12
                                    }
                                }

                                Text {
                                    visible: index === root.selectedIndex
                                    text: modelData.hint || "Enter"
                                    color: Colors.accent
                                    font.family: Typography.fontFamily
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: root.results.length === 0
                        spacing: 10

                        Controls.Icon {
                            Layout.alignment: Qt.AlignHCenter
                            icon: Icons.appSearch
                            color: Colors.muted
                            size: 30
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "No results found"
                            color: Colors.muted
                            horizontalAlignment: Text.AlignHCenter
                            font.family: Typography.fontFamily
                            font.pixelSize: 14
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Colors.panelBorder
                    opacity: 0.55
                }

                Controls.KeyHintBar {
                    hints: "↑/↓ move · Enter run/copy · =2+2 calculator · lock/reboot actions · Esc close"
                }
            }
        }
    }
}
