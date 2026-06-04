// Kitana managed Quickshell launcher

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets as QW
import ".."
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

    function launchApp(app): void {
        if (!app)
            return;

        close();

        if (typeof app.execute === "function") {
            app.execute();
            return;
        }
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
            launchApp(results[selectedIndex]);
    }

    function iconSource(app): string {
        const icon = app && app.icon ? app.icon : "application-x-executable";
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
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Math.max(72, Math.floor(parent.height * 0.12))
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
                    font.family: settings.fontFamily
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

                        Text {
                            text: "󰍉"
                            color: Colors.muted
                            font.family: settings.fontFamily
                            font.pixelSize: 18
                        }

                        TextInput {
                            id: search
                            Layout.fillWidth: true
                            focus: true
                            color: Colors.panelInputForeground
                            selectionColor: Colors.accentBackground
                            selectedTextColor: Colors.foreground
                            font.family: settings.fontFamily
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
                                onClicked: root.launchApp(modelData)
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
                                            text: (modelData.name || "A").charAt(0).toUpperCase()
                                            color: Colors.accent
                                            font.family: settings.fontFamily
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
                                        font.family: settings.fontFamily
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.comment || modelData.genericName || modelData.id || ""
                                        color: Colors.muted
                                        elide: Text.ElideRight
                                        font.family: settings.fontFamily
                                        font.pixelSize: 12
                                    }
                                }

                                Text {
                                    visible: index === root.selectedIndex
                                    text: "Enter"
                                    color: Colors.accent
                                    font.family: settings.fontFamily
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: root.results.length === 0
                        spacing: 10

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰅙"
                            color: Colors.muted
                            font.family: settings.fontFamily
                            font.pixelSize: 30
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "No applications found"
                            color: Colors.muted
                            horizontalAlignment: Text.AlignHCenter
                            font.family: settings.fontFamily
                            font.pixelSize: 14
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "↑/↓ to move · Home/End jump · Enter launch · Esc close"
                    color: Colors.muted
                    horizontalAlignment: Text.AlignHCenter
                    font.family: settings.fontFamily
                    font.pixelSize: 11
                }
            }
        }
    }
}
