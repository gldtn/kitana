// Kitana managed Quickshell module

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../custom" as Custom

PanelWindow {
    id: root

    Custom.Settings {
        id: settings
    }

    visible: false
    focusable: true
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onVisibleChanged: if (visible) Qt.callLater(() => {
        overlay.forceActiveFocus();
        grid.forceActiveFocus();
    })

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    property var wallpapers: []
    property var filteredWallpapers: []
    property string query: ""
    property string statusText: ""
    property bool helpVisible: false
    property bool searchActive: false
    property string kitanaDir: Quickshell.env("KITANA_DIR") || Quickshell.env("HOME") + "/.local/share/kitana"
    property int cardWidth: Math.min(900, width - 160)
    property int cardHeight: Math.min(560, height - 160)

    function basename(path) {
        return path.split("/").pop();
    }

    function fileUrl(path) {
        return "file://" + path;
    }

    function refreshFilter() {
        const needle = query.toLowerCase();
        filteredWallpapers = wallpapers.filter(path => basename(path).toLowerCase().indexOf(needle) !== -1);
        grid.currentIndex = filteredWallpapers.length > 0 ? 0 : -1;
        if (visible && !searchActive)
            Qt.callLater(() => grid.forceActiveFocus());
    }

    function applyWallpaper(path) {
        if (!path)
            return;

        statusText = "Applying " + basename(path) + "...";
        applyProcess.exec([kitanaDir + "/bin/kitana-wallpaper", path]);
    }

    function applyCurrent() {
        applyWallpaper(filteredWallpapers[grid.currentIndex]);
    }

    function gridColumns() {
        return Math.max(1, Math.floor(grid.width / 200));
    }

    function moveSelection(delta) {
        if (filteredWallpapers.length === 0)
            return;

        const next = (grid.currentIndex + delta + filteredWallpapers.length) % filteredWallpapers.length;
        grid.currentIndex = next;
        grid.positionViewAtIndex(next, GridView.Contain);
    }

    function handleKey(event) {
        if (searchActive)
            return;

        const text = event.text.toLowerCase();
        const key = event.key;

        if (key === Qt.Key_Escape) {
            close();
            event.accepted = true;
        } else if (key === Qt.Key_Return || key === Qt.Key_Enter || key === Qt.Key_Space) {
            applyCurrent();
            event.accepted = true;
        } else if (key === Qt.Key_Left || key === Qt.Key_H) {
            moveSelection(-1);
            event.accepted = true;
        } else if (key === Qt.Key_Right || key === Qt.Key_L) {
            moveSelection(1);
            event.accepted = true;
        } else if (key === Qt.Key_Up || key === Qt.Key_K) {
            moveSelection(-gridColumns());
            event.accepted = true;
        } else if (key === Qt.Key_Down || key === Qt.Key_J) {
            moveSelection(gridColumns());
            event.accepted = true;
        } else if (text === "/") {
            searchActive = true;
            search.forceActiveFocus();
            event.accepted = true;
        } else if (text === "?") {
            helpVisible = !helpVisible;
            event.accepted = true;
        }
    }

    function open(): void {
        visible = true;
        query = "";
        helpVisible = false;
        searchActive = false;
        search.text = "";
        statusText = "Loading wallpapers...";
        listProcess.exec([kitanaDir + "/bin/kitana-wallpaper", "--list"]);
        overlay.forceActiveFocus();
        grid.forceActiveFocus();
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
        target: "kitana-wallpaper"

        function open(): void { root.open(); }
        function close(): void { root.close(); }
        function toggle(): void { root.toggle(); }
    }

    Process {
        id: listProcess

        stdout: StdioCollector {
            onStreamFinished: {
                root.wallpapers = text.trim().length > 0 ? text.trim().split("\n") : [];
                root.statusText = root.wallpapers.length > 0 ? "" : "No wallpapers found";
                root.refreshFilter();
            }
        }
    }

    Process {
        id: applyProcess

        onRunningChanged: {
            if (!running && root.visible) {
                root.statusText = "Wallpaper applied";
                root.close();
            }
        }
    }

    FocusScope {
        id: overlay

        anchors.fill: parent
        focus: true
        activeFocusOnTab: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: event => root.handleKey(event)

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
            color: Colors.panelStrong
            border.color: Colors.panelBorder
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

            Text {
                Layout.fillWidth: true
                visible: root.statusText.length > 0
                text: root.statusText
                color: Colors.muted
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize
            }

            GridView {
                id: grid

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                focus: true
                activeFocusOnTab: true
                model: root.filteredWallpapers
                cellWidth: Math.floor(width / Math.max(1, Math.floor(width / 200)))
                cellHeight: cellWidth * 0.62
                keyNavigationWraps: true

                Keys.priority: Keys.BeforeItem
                Keys.onPressed: event => root.handleKey(event)

                delegate: Rectangle {
                    id: card

                    required property int index
                    required property string modelData
                    readonly property bool selected: index === grid.currentIndex

                    width: grid.cellWidth - 12
                    height: grid.cellHeight - 12
                    radius: 14
                    color: Colors.surface
                    border.color: selected || mouse.containsMouse ? Colors.panelBorderStrong : Colors.panelBorder
                    border.width: 1
                    clip: true
                    antialiasing: true

                    Image {
                        id: thumbnail

                        anchors.fill: parent
                        source: root.fileUrl(card.modelData)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        visible: false
                    }

                    Rectangle {
                        id: thumbnailMask

                        anchors.fill: parent
                        radius: parent.radius
                        visible: false
                        layer.enabled: true
                    }

                    MultiEffect {
                        anchors.fill: thumbnail
                        source: thumbnail
                        maskEnabled: true
                        maskSource: thumbnailMask
                    }

                    Rectangle {
                        anchors.fill: parent
                        visible: card.selected
                        color: Colors.surfaceHighlight
                        border.color: Colors.accent
                        border.width: 1
                        radius: parent.radius
                        antialiasing: true
                        z: 10
                    }

                    Item {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 34

                        Rectangle {
                            anchors.fill: parent
                            radius: card.radius
                            color: Colors.imageOverlay
                            antialiasing: true

                            Rectangle {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: parent.radius
                                color: parent.color
                            }
                        }

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: Text.AlignVCenter
                            text: root.basename(card.modelData)
                            elide: Text.ElideRight
                            color: "white"
                            font.family: settings.fontFamily
                            font.pixelSize: settings.textPixelSize
                        }
                    }

                    MouseArea {
                        id: mouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: grid.currentIndex = card.index
                        onClicked: {
                            grid.currentIndex = card.index;
                            root.applyWallpaper(card.modelData);
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.searchActive ? 38 : (root.helpVisible ? 56 : 24)
                radius: 10
                color: root.searchActive ? Colors.surface : "transparent"
                border.color: root.searchActive ? Colors.panelBorder : "transparent"
                border.width: root.searchActive ? 1 : 0

                TextInput {
                    id: search

                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter
                    visible: root.searchActive
                    clip: true
                    color: Colors.foreground
                    selectionColor: Colors.accent
                    selectedTextColor: Colors.accentText
                    font.family: settings.fontFamily
                    font.pixelSize: settings.textPixelSize

                    onTextChanged: {
                        root.query = text;
                        root.refreshFilter();
                    }

                    Keys.onEscapePressed: {
                        root.searchActive = false;
                        grid.forceActiveFocus();
                    }

                    Keys.onReturnPressed: {
                        root.searchActive = false;
                        grid.forceActiveFocus();
                    }
                }

                Text {
                    anchors.fill: parent
                    visible: !root.searchActive
                    verticalAlignment: Text.AlignVCenter
                    text: root.helpVisible ? "arrows/hjkl move  ·  enter/space apply  ·  / search  ·  ? hide help  ·  esc close" : "? help  ·  arrows/hjkl move  ·  / search  ·  enter/space apply  ·  esc close"
                    color: Colors.muted
                    font.family: settings.fontFamily
                    font.pixelSize: settings.textPixelSize
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
            }
        }
    }
}
