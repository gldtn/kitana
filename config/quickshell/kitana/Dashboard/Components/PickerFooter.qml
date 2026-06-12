// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property var dashboard: null

    readonly property bool searchActive: dashboard && dashboard.pickerSearchActive
    readonly property bool helpVisible: dashboard && dashboard.pickerHelpVisible

    Layout.fillWidth: true
    Layout.preferredHeight: searchActive ? 36 : (helpVisible ? 52 : 24)
    radius: 10
    color: searchActive ? Colors.panelCardBackground : "transparent"
    border.color: searchActive ? Colors.panelBorder : "transparent"
    border.width: searchActive ? 1 : 0

    TextInput {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        verticalAlignment: TextInput.AlignVCenter
        visible: root.searchActive
        clip: true
        text: root.dashboard ? root.dashboard.pickerQuery : ""
        color: Colors.primaryForeground
        selectionColor: Colors.panelButtonBackgroundActive
        selectedTextColor: Colors.primaryForeground
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize
        onVisibleChanged: if (visible) forceActiveFocus()
        onTextChanged: {
            if (!root.dashboard)
                return;
            root.dashboard.pickerQuery = text;
            root.dashboard.refreshPickerFilter();
        }
        Keys.onEscapePressed: {
            if (!root.dashboard)
                return;
            root.dashboard.pickerSearchActive = false;
            root.dashboard.focusPanel();
        }
        Keys.onReturnPressed: {
            if (!root.dashboard)
                return;
            root.dashboard.pickerSearchActive = false;
            root.dashboard.focusPanel();
        }
    }

    Text {
        anchors.fill: parent
        visible: !root.searchActive
        verticalAlignment: Text.AlignVCenter
        text: root.helpVisible ? "arrows/hjkl move  ·  p/n pages  ·  enter/space apply  ·  / search  ·  ? hide help  ·  esc close" : "? help  ·  arrows/hjkl move  ·  / search  ·  enter/space apply  ·  esc close"
        color: Colors.mutedForeground
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
    }
}
