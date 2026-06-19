// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Item {
    id: root

    Custom.Settings { id: settings }

    property var dashboard: null

    readonly property bool searchActive: dashboard && dashboard.pickerSearchActive
    readonly property bool helpVisible: dashboard && dashboard.pickerHelpVisible

    Layout.fillWidth: true
    Layout.preferredHeight: searchActive ? 36 : (helpVisible ? 52 : 24)

    // Picker search input
    Controls.InputField {
        id: pickerInput

        anchors.fill: parent
        visible: root.searchActive
        fieldHeight: 36
        text: root.dashboard ? root.dashboard.pickerQuery : ""
        onVisibleChanged: if (visible) forceActiveFocus()
        onTextChanged: {
            if (!root.dashboard)
                return;
            root.dashboard.pickerQuery = text;
            root.dashboard.refreshPickerFilter();
        }
        onEscaped: {
            if (!root.dashboard)
                return;
            root.dashboard.pickerSearchActive = false;
            root.dashboard.focusPanel();
        }
        onAccepted: {
            if (!root.dashboard)
                return;
            root.dashboard.pickerSearchActive = false;
            root.dashboard.focusPanel();
        }
    }

    // Picker keyboard help text
    Text {
        anchors.fill: parent
        visible: !root.searchActive
        verticalAlignment: Text.AlignVCenter
        text: root.helpVisible ? "arrows/hjkl move  ·  p/n pages  ·  enter/space apply  ·  / search  ·  ? hide help  ·  esc close" : "? help  ·  arrows/hjkl move  ·  / search  ·  enter/space apply  ·  esc close"
        color: Colors.fgSecondary
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
    }
}
