// Kitana managed Quickshell module

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../Components/Controls" as Controls
import "../custom" as Custom

PanelWindow {
    id: root

    Custom.Settings {
        id: settings
    }

    visible: panelVisible
    focusable: true
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    BackgroundEffect.blurRegion: Region { item: backdrop }

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
    property bool panelVisible: false
    property bool helpVisible: false
    property bool searchActive: false
    property string kitanaDir: Quickshell.env("KITANA_DIR") || Quickshell.env("HOME") + "/.local/share/kitana"
    property int selectedIndex: -1
    readonly property int cardWidth: Math.min(900, width - 160)
    readonly property int cardHeight: Math.min(560, height - 160)

    function basename(path) {
        return path.split("/").pop();
    }

    function fileUrl(path) {
        return "file://" + path;
    }

    function refreshFilter() {
        const needle = query.toLowerCase();
        filteredWallpapers = wallpapers.filter(path => basename(path).toLowerCase().indexOf(needle) !== -1);
        selectedIndex = filteredWallpapers.length > 0 ? 0 : -1;
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
        applyWallpaper(filteredWallpapers[selectedIndex]);
    }

    function gridColumns() {
        return Math.max(1, Math.floor(grid.width / 200));
    }

    function moveSelection(delta) {
        if (filteredWallpapers.length === 0)
            return;

        const next = (selectedIndex + delta + filteredWallpapers.length) % filteredWallpapers.length;
        selectedIndex = next;
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
        panelVisible = true;
        query = "";
        helpVisible = false;
        searchActive = false;
        statusText = "Loading wallpapers...";
        listProcess.exec([kitanaDir + "/bin/kitana-wallpaper", "--list"]);
        overlay.forceActiveFocus();
        grid.forceActiveFocus();
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

    // Wallpaper picker IPC command bridge
    IpcHandler {
        target: "kitana-wallpaper"

        function open(): void { root.open(); }
        function close(): void { root.close(); }
        function toggle(): void { root.toggle(); }
    }

    // Wallpaper list command runner
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

    // Wallpaper apply command runner
    Process {
        id: applyProcess

        onRunningChanged: {
            if (!running && root.visible) {
                root.statusText = "Wallpaper applied";
                root.close();
            }
        }
    }

    // Full-screen wallpaper picker overlay
    FocusScope {
        id: overlay

        anchors.fill: parent
        focus: true
        activeFocusOnTab: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: event => root.handleKey(event)

        // Blurred wallpaper picker backdrop
        Controls.BlurredBackdrop {
            id: backdrop

            anchors.fill: parent
        }

        // Full-screen close catcher
        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }

        // Main wallpaper picker card
        Rectangle {
            width: root.cardWidth
            height: root.cardHeight
            anchors.centerIn: parent
            radius: 18
            color: Colors.bgPrimary
            border.color: Colors.borderFaint
            border.width: 1

            // Wallpaper picker content stack
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                // Wallpaper loading/apply status
                Text {
                    Layout.fillWidth: true
                    visible: root.statusText.length > 0
                    text: root.statusText
                    color: Colors.fgSecondary
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize
                }

                // Wallpaper thumbnail grid
                GridView {
                    id: grid

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    focus: true
                    activeFocusOnTab: true
                    model: root.filteredWallpapers
                    currentIndex: root.selectedIndex
                    cellWidth: Math.floor(width / Math.max(1, Math.floor(width / 200)))
                    cellHeight: cellWidth * 0.62
                    keyNavigationWraps: true

                    Keys.priority: Keys.BeforeItem
                    Keys.onPressed: event => root.handleKey(event)

                    // One wallpaper thumbnail card
                    delegate: Rectangle {
                        id: card

                        required property int index
                        required property string modelData
                        readonly property bool selected: index === root.selectedIndex

                        width: grid.cellWidth - 12
                        height: grid.cellHeight - 12
                        radius: 14
                        color: Colors.bgTertiary
                        border.color: selected || mouse.containsMouse ? Colors.borderAccent : Colors.borderFaint
                        border.width: 1
                        clip: true
                        antialiasing: true

                        // Raw wallpaper thumbnail image
                        Image {
                            id: thumbnail

                            anchors.fill: parent
                            source: root.fileUrl(card.modelData)
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            visible: false
                        }

                        // Rounded thumbnail mask
                        Rectangle {
                            id: thumbnailMask

                            anchors.fill: parent
                            radius: parent.radius
                            visible: false
                            layer.enabled: true
                        }

                        // Masked wallpaper thumbnail
                        MultiEffect {
                            anchors.fill: thumbnail
                            source: thumbnail
                            maskEnabled: true
                            maskSource: thumbnailMask
                        }

                        // Selected wallpaper overlay
                        Rectangle {
                            anchors.fill: parent
                            visible: card.selected
                            color: Colors.subtlePrimary
                            border.color: Colors.fgAccent
                            border.width: 1
                            radius: parent.radius
                            antialiasing: true
                            z: 10
                        }

                        // Wallpaper filename overlay
                        Item {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 34

                            // Filename background overlay
                            Rectangle {
                                anchors.fill: parent
                                radius: card.radius
                                color: Colors.scrimTertiary
                                antialiasing: true

                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: parent.radius
                                    color: parent.color
                                }
                            }

                            // Wallpaper filename label
                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                verticalAlignment: Text.AlignVCenter
                                text: root.basename(card.modelData)
                                elide: Text.ElideRight
                                color: Colors.fgPrimary
                                font.family: Typography.fontFamily
                                font.pixelSize: settings.textPixelSize
                            }
                        }

                        // Wallpaper selection click target
                        MouseArea {
                            id: mouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.selectedIndex = card.index
                            onClicked: {
                                root.selectedIndex = card.index;
                                root.applyWallpaper(card.modelData);
                            }
                        }
                    }
                }

                // Search field or help footer
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.searchActive ? 38 : (root.helpVisible ? 56 : 24)
                    radius: 10
                    color: root.searchActive ? Colors.bgTertiary : "transparent"
                    border.color: root.searchActive ? Colors.borderFaint : "transparent"
                    border.width: root.searchActive ? 1 : 0

                    // Wallpaper search input
                    TextInput {
                        id: search

                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        visible: root.searchActive
                        text: root.query
                        clip: true
                        color: Colors.fgPrimary
                        selectionColor: Colors.fgAccent
                        selectedTextColor: Colors.fgOnPrimary
                        font.family: Typography.fontFamily
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

                    // Wallpaper keyboard help text
                    Text {
                        anchors.fill: parent
                        visible: !root.searchActive
                        verticalAlignment: Text.AlignVCenter
                        text: root.helpVisible ? "arrows/hjkl move  ·  enter/space apply  ·  / search  ·  ? hide help  ·  esc close" : "? help  ·  arrows/hjkl move  ·  / search  ·  enter/space apply  ·  esc close"
                        color: Colors.fgSecondary
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}
