// Kitana managed Quickshell bar

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "."

ShellRoot {
  id: root

  property var workspaceSets: [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]]

  function range(start, end) {
    const workspaces = [];
    for (let workspace = start; workspace <= end; workspace++) workspaces.push(workspace);
    return workspaces;
  }

  function screenIndex(screen) {
    for (let i = 0; i < Quickshell.screens.length; i++) {
      if (Quickshell.screens[i] === screen) return i;
    }
    return 0;
  }

  function workspacesFor(screen) {
    const index = screenIndex(screen);
    const configured = Quickshell.screens.length === 1 ? range(1, 10) : workspaceSets[Math.min(index, workspaceSets.length - 1)];
    const activeWorkspace = Hyprland.workspaces.values.find(workspace => workspace.active);

    if (Quickshell.screens.length === 1 && activeWorkspace && activeWorkspace.id > 0 && configured.indexOf(activeWorkspace.id) === -1) {
      return [activeWorkspace.id].concat(configured);
    }

    return configured;
  }

  function screenName(screen) {
    return screen && screen.name ? screen.name : "";
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData

      screen: modelData
      implicitHeight: 40
      exclusiveZone: 48

      anchors {
        top: true
        left: true
        right: true
      }

      margins {
        top: 8
        left: 10
        right: 10
      }

      color: "transparent"

      Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
          Hyprland.refreshWorkspaces();
          audioPoll.exec(["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{ printf \"%s %d%%\", ($0 ~ /MUTED/ ? \"muted\" : \"volume\"), $2 * 100 }'"]);
          networkPoll.exec(["sh", "-c", "iface=$(ip route get 1.1.1.1 2>/dev/null | sed -n 's/.* dev \\([^ ]*\\).*/\\1/p'); [ -n \"$iface\" ] && printf '%s' \"$iface\" || printf offline"]);
          bluetoothPoll.exec(["sh", "-c", "if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then count=$(bluetoothctl devices Connected 2>/dev/null | wc -l); [ \"$count\" -gt 0 ] && printf 'bt %s' \"$count\" || printf 'bt on'; else printf 'bt off'; fi"]);
        }
      }

      Process {
        id: audioPoll
        stdout: StdioCollector { onStreamFinished: audioText.text = text.trim() || "volume --" }
      }

      Process {
        id: networkPoll
        stdout: StdioCollector { onStreamFinished: networkText.text = text.trim() || "offline" }
      }

      Process {
        id: bluetoothPoll
        stdout: StdioCollector { onStreamFinished: bluetoothText.text = text.trim() || "bt off" }
      }

      Process { id: workspaceSwitch }

      Rectangle {
        anchors.fill: parent
        color: "transparent"

        RowLayout {
          anchors.fill: parent
          spacing: 10

          Rectangle {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.preferredHeight: 32
            Layout.preferredWidth: workspaceRow.implicitWidth + 18
            radius: height / 2
            color: Colors.background
            border.color: Colors.surfaceAlt
            border.width: 1

            Row {
              id: workspaceRow
              anchors.centerIn: parent
              spacing: 6

              Repeater {
                model: root.workspacesFor(panel.screen)

                Rectangle {
                  id: workspacePill
                  property int workspaceId: modelData
                  property bool active: Hyprland.workspaces.values.some(workspace => workspace.id === workspaceId && workspace.active)
                  property bool occupied: Hyprland.workspaces.values.some(workspace => workspace.id === workspaceId && workspace.toplevels.values.length > 0)

                  width: active ? 30 : 22
                  height: 22
                  radius: 11
                  color: active ? Colors.accent : (occupied ? Colors.surfaceAlt : Colors.surface)

                  Text {
                    anchors.centerIn: parent
                    text: workspacePill.workspaceId
                    color: workspacePill.active ? Colors.accentText : Colors.foreground
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: workspaceSwitch.exec([
                      "sh",
                      "-c",
                      "monitor=$1; workspace=$2; [ -n \"$monitor\" ] && hyprctl dispatch focusmonitor \"$monitor\" >/dev/null 2>&1 || true; hyprctl dispatch \"hl.dsp.focus({ workspace = $workspace })\" >/dev/null 2>&1 || hyprctl dispatch workspace \"$workspace\" >/dev/null 2>&1",
                      "kitana-workspace",
                      root.screenName(panel.screen),
                      String(workspacePill.workspaceId)
                    ])
                  }
                }
              }
            }
          }

          Item { Layout.fillWidth: true }

          Rectangle {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.preferredHeight: 32
            Layout.preferredWidth: clockText.implicitWidth + 26
            radius: height / 2
            color: Colors.background
            border.color: Colors.surfaceAlt
            border.width: 1

            Text {
              id: clockText
              anchors.centerIn: parent
              text: Qt.formatDateTime(new Date(), "ddd MMM d  h:mm AP")
              color: Colors.foreground
              font.pixelSize: 13
              font.weight: Font.DemiBold

              Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clockText.text = Qt.formatDateTime(new Date(), "ddd MMM d  h:mm AP")
              }
            }
          }

          Item { Layout.fillWidth: true }

          Rectangle {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            Layout.preferredHeight: 32
            Layout.preferredWidth: statusRow.implicitWidth + 22
            radius: height / 2
            color: Colors.background
            border.color: Colors.surfaceAlt
            border.width: 1

            Row {
              id: statusRow
              anchors.centerIn: parent
              spacing: 12

              Text { id: bluetoothText; text: "bt --"; color: Colors.foreground; font.pixelSize: 12; font.weight: Font.DemiBold }
              Text { id: networkText; text: "net --"; color: Colors.foreground; font.pixelSize: 12; font.weight: Font.DemiBold }
              Text { id: audioText; text: "vol --"; color: Colors.foreground; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
          }
        }
      }
    }
  }
}
