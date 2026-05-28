// Kitana managed Quickshell module

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../custom" as Custom

Rectangle {
    Custom.Settings {
        id: settings
    }

    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
    Layout.preferredHeight: settings.pillHeight
    Layout.preferredWidth: statusRow.implicitWidth + settings.statusHorizontalPadding

    radius: height / settings.radiusDivisor
    color: Colors.background
    border.color: Colors.surfaceAlt
    border.width: settings.borderWidth

    property string bluetoothValue: "--"
    property string networkValue: "--"
    property string audioIcon: "󰕾"
    property string audioValue: "--"

    function updateAudio(raw) {
        const parts = raw.trim().split(/\s+/);
        audioIcon = parts[0] === "muted" ? "󰝟" : "󰕾";
        audioValue = parts.length > 1 ? parts[1] : "--";
    }

    function updateNetwork(raw) {
        const value = raw.trim();
        networkValue = value && value !== "offline" ? value : "off";
    }

    function updateBluetooth(raw) {
        const value = raw.trim();
        bluetoothValue = value.replace(/^bt\s*/, "") || "off";
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            audioPoll.exec(["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{ printf \"%s %d%%\", ($0 ~ /MUTED/ ? \"muted\" : \"volume\"), $2 * 100 }'"]);
            networkPoll.exec(["sh", "-c", "iface=$(ip route get 1.1.1.1 2>/dev/null | sed -n 's/.* dev \\([^ ]*\\).*/\\1/p'); [ -n \"$iface\" ] && printf '%s' \"$iface\" || printf offline"]);
            bluetoothPoll.exec(["sh", "-c", "if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then count=$(bluetoothctl devices Connected 2>/dev/null | wc -l); [ \"$count\" -gt 0 ] && printf 'bt %s' \"$count\" || printf 'bt on'; else printf 'bt off'; fi"]);
        }
    }

    Process {
        id: audioPoll
        stdout: StdioCollector {
            onStreamFinished: updateAudio(text)
        }
    }

    Process {
        id: networkPoll
        stdout: StdioCollector {
            onStreamFinished: updateNetwork(text)
        }
    }

    Process {
        id: bluetoothPoll
        stdout: StdioCollector {
            onStreamFinished: updateBluetooth(text)
        }
    }

    Row {
        id: statusRow

        anchors.centerIn: parent
        spacing: settings.statusSpacing

        Row {
            spacing: settings.statusItemSpacing
            Text {
                text: "󰂯"
                color: Colors.accent
                font.family: settings.fontFamily
                font.pixelSize: settings.iconPixelSize
            }
            Text {
                text: bluetoothValue
                color: Colors.foreground
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }
        }

        Row {
            spacing: settings.statusItemSpacing
            Text {
                text: networkValue === "off" ? "󰤭" : "󰤨"
                color: Colors.accent
                font.family: settings.fontFamily
                font.pixelSize: settings.iconPixelSize
            }
            Text {
                text: networkValue
                color: Colors.foreground
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }
        }

        Row {
            spacing: settings.statusItemSpacing
            Text {
                text: audioIcon
                color: Colors.accent
                font.family: settings.fontFamily
                font.pixelSize: settings.iconPixelSize
            }
            Text {
                text: audioValue
                color: Colors.foreground
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }
        }
    }
}
