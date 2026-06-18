// Kitana managed Quickshell shortcuts panel

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../Components/Controls" as Controls
import "../custom" as Custom

PanelWindow {
    id: root

    Custom.Settings { id: settings }

    property var panelScreen: null
    property bool panelVisible: false
    property string query: ""
    property var shortcuts: []
    property var filteredShortcuts: []
    property string statusText: "Loading shortcuts..."
    property int selectedIndex: 0

    function open(): void {
        panelVisible = true;
        query = "";
        statusText = "Loading shortcuts...";
        refreshShortcuts();
        Qt.callLater(() => searchInput.forceActiveFocus());
    }

    function close(): void {
        panelVisible = false;
    }

    function toggle(): void {
        panelVisible ? close() : open();
    }

    function refreshShortcuts(): void {
        shortcutsProcess.exec(["hyprctl", "binds", "-j"]);
    }

    function moveSelection(delta: int): void {
        if (filteredShortcuts.length === 0)
            return;
        selectedIndex = Math.max(0, Math.min(filteredShortcuts.length - 1, selectedIndex + delta));
        shortcutList.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function handleKey(event: var): void {
        if (event.key === Qt.Key_Escape) {
            close();
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            moveSelection(1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            moveSelection(-1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Home) {
            selectedIndex = filteredShortcuts.length > 0 ? 0 : -1;
            if (selectedIndex >= 0)
                shortcutList.positionViewAtIndex(selectedIndex, ListView.Beginning);
            event.accepted = true;
        } else if (event.key === Qt.Key_End) {
            selectedIndex = filteredShortcuts.length - 1;
            if (selectedIndex >= 0)
                shortcutList.positionViewAtIndex(selectedIndex, ListView.End);
            event.accepted = true;
        }
    }

    function modifiers(mask: int): string {
        const parts = [];
        if (mask & 64)
            parts.push("Super");
        if (mask & 4)
            parts.push("Ctrl");
        if (mask & 1)
            parts.push("Shift");
        if (mask & 8)
            parts.push("Alt");
        return parts.join(" + ");
    }

    function displayKey(key: string): string {
        if (key === "RETURN")
            return "Enter";
        if (key === "SLASH")
            return "/";
        if (key === "COMMA")
            return ",";
        if (key.indexOf("XF86") === 0)
            return key.replace("XF86", "");
        return key;
    }

    function shortcutLabel(item: var): string {
        const mods = modifiers(item.modmask || 0);
        const key = displayKey(item.key || "");
        return mods.length > 0 && key.length > 0 ? mods + " + " + key : key;
    }

    function fallbackDescription(item: var): string {
        if (item.description && item.description.length > 0)
            return item.description;
        if (item.dispatcher && item.dispatcher !== "__lua")
            return item.dispatcher + (item.arg ? " " + item.arg : "");
        return "Unlabeled binding";
    }

    function categoryFor(item: var): string {
        const description = fallbackDescription(item).toLowerCase();
        if (description.indexOf("workspace") !== -1 || description.indexOf("window") !== -1 || description.indexOf("focus") !== -1 || description.indexOf("swap") !== -1)
            return "Window management";
        if (description.indexOf("screenshot") !== -1)
            return "Screenshots";
        if (description.indexOf("quickshell") !== -1 || description.indexOf("theme") !== -1 || description.indexOf("wallpaper") !== -1 || description.indexOf("notification") !== -1)
            return "Kitana";
        if (description.indexOf("volume") !== -1 || description.indexOf("audio") !== -1 || description.indexOf("brightness") !== -1 || description.indexOf("player") !== -1)
            return "Media";
        if (description.indexOf("lock") !== -1 || description.indexOf("session") !== -1)
            return "Session";
        return "Applications";
    }

    function loadShortcuts(text: string): void {
        try {
            const parsed = JSON.parse(text);
            const items = [];

            for (const item of parsed) {
                const key = shortcutLabel(item);
                if (!key || key.length === 0)
                    continue;

                items.push({
                    keys: key,
                    description: fallbackDescription(item),
                    category: categoryFor(item),
                    rawKey: item.key || "",
                    dispatcher: item.dispatcher || ""
                });
            }

            shortcuts = items.sort((a, b) => a.description.localeCompare(b.description));
            statusText = shortcuts.length > 0 ? "" : "No shortcuts found";
            filterShortcuts();
        } catch (error) {
            shortcuts = [];
            filteredShortcuts = [];
            statusText = "Unable to read Hyprland shortcuts";
        }
    }

    function filterShortcuts(): void {
        const needle = query.toLowerCase().trim();
        filteredShortcuts = needle.length === 0 ? shortcuts : shortcuts.filter(item => {
            return item.keys.toLowerCase().indexOf(needle) !== -1
                || item.description.toLowerCase().indexOf(needle) !== -1
                || item.category.toLowerCase().indexOf(needle) !== -1;
        });
        selectedIndex = filteredShortcuts.length > 0 ? 0 : -1;
    }

    screen: panelScreen
    visible: panelVisible
    focusable: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    BackgroundEffect.blurRegion: Region { item: backdrop }

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    // Hyprland binds command runner
    Process {
        id: shortcutsProcess

        stdout: StdioCollector {
            onStreamFinished: root.loadShortcuts(text)
        }

        onRunningChanged: if (!running && root.shortcuts.length === 0 && root.statusText === "Loading shortcuts...") root.statusText = "No shortcuts found"
    }

    // Shortcuts panel IPC command bridge
    IpcHandler {
        target: "kitana-shortcuts"

        function open(): void { root.open(); }
        function close(): void { root.close(); }
        function toggle(): void { root.toggle(); }
    }

    // Full-screen close and keyboard handler
    MouseArea {
        id: closeArea
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.close()
        Keys.onPressed: event => root.handleKey(event)
        onClicked: root.close()
    }

    // Blurred shortcuts panel backdrop
    Controls.BlurredBackdrop {
        id: backdrop

        anchors.fill: parent
    }

    // Main shortcuts card
    Rectangle {
        width: Math.min(760, parent.width - 96)
        height: Math.min(620, parent.height - 120)
        anchors.centerIn: parent
        radius: 18
        color: Colors.panelBackground
        border.color: Colors.panelBorder
        border.width: 1
        clip: true

        // Prevent clicks inside card from closing panel
        MouseArea {
            anchors.fill: parent
            onPressed: mouse => mouse.accepted = true
        }

        // Shortcuts content stack
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Shortcuts panel header
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Controls.Icon {
                    name: "input.keyboard"
                    tone: "accent"
                    size: settings.iconPixelSize + 4
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        Layout.fillWidth: true
                        text: "Shortcuts"
                        color: Colors.foreground
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize + 4
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Hyprland keybinds"
                        color: Colors.foregroundMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                    }
                }
            }

            // Shortcut search input frame
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: 11
                color: Colors.cardBackground
                border.color: searchInput.activeFocus ? Colors.controlActiveBorder : Colors.panelBorder
                border.width: 1

                // Search icon and input row
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Controls.Icon {
                        name: "search"
                        tone: "muted"
                        sizeRole: "bar"
                    }

                    TextInput {
                        id: searchInput

                        Layout.fillWidth: true
                        text: root.query
                        color: Colors.foreground
                        selectionColor: Colors.controlActiveBackground
                        selectedTextColor: Colors.foreground
                        verticalAlignment: TextInput.AlignVCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                        clip: true
                        onTextChanged: {
                            root.query = text;
                            root.filterShortcuts();
                        }

                        Keys.onPressed: event => root.handleKey(event)
                    }
                }
            }

            // Shortcut loading or empty status
            Text {
                Layout.fillWidth: true
                visible: root.statusText.length > 0
                text: root.statusText
                color: Colors.foregroundMuted
                horizontalAlignment: Text.AlignHCenter
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
            }

            // Filtered shortcut list
            ListView {
                id: shortcutList

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 8
                model: root.filteredShortcuts
                currentIndex: root.selectedIndex

                // One shortcut result row
                delegate: Rectangle {
                    id: shortcutDelegate

                    required property int index
                    required property var modelData

                    width: shortcutList.width
                    height: 54
                    radius: 12
                    color: shortcutDelegate.index === root.selectedIndex ? Colors.controlActiveBackground : (shortcutMouse.containsMouse ? Colors.controlHoverBackground : Colors.cardBackground)
                    border.color: shortcutDelegate.index === root.selectedIndex ? Colors.controlActiveBorder : Colors.panelBorder
                    border.width: 1

                    // Shortcut key and description row
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        // Shortcut key badge
                        Rectangle {
                            Layout.preferredWidth: Math.max(150, keyText.implicitWidth + 18)
                            Layout.preferredHeight: 30
                            radius: 9
                            color: Colors.controlActiveBackground
                            border.color: Colors.controlActiveBorder
                            border.width: 1

                            // Shortcut key label
                            Text {
                                id: keyText
                                anchors.centerIn: parent
                                text: shortcutDelegate.modelData.keys
                                color: Colors.foreground
                                font.family: Typography.fontFamily
                                font.pixelSize: settings.textPixelSize
                                font.weight: Font.Bold
                            }
                        }

                        // Shortcut description and category
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                Layout.fillWidth: true
                                text: shortcutDelegate.modelData.description
                                color: Colors.foreground
                                elide: Text.ElideRight
                                font.family: Typography.fontFamily
                                font.pixelSize: settings.textPixelSize
                                font.weight: Font.Bold
                            }

                            Text {
                                Layout.fillWidth: true
                                text: shortcutDelegate.modelData.category
                                color: Colors.foregroundMuted
                                elide: Text.ElideRight
                                font.family: Typography.fontFamily
                                font.pixelSize: settings.textPixelSize - 1
                            }
                        }
                    }

                    // Shortcut hover selection target
                    MouseArea {
                        id: shortcutMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: root.selectedIndex = shortcutDelegate.index
                    }
                }
            }

            // Footer divider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.panelBorder
                opacity: 0.55
            }

            // Shortcuts keyboard hints
            Controls.KeyHintBar {
                hints: "↑/↓ move · Esc close"
            }
        }
    }
}
