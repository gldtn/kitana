// Kitana managed Quickshell control

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

// Flux-style pagination row with compact page buttons and ellipses.
RowLayout {
    id: root

    Custom.Settings {
        id: settings
    }

    property int currentPage: 0
    property int pageCount: 1
    property int maxPageButtons: 7
    property bool wrap: false
    readonly property int normalizedPageCount: Math.max(1, pageCount)
    readonly property int normalizedCurrentPage: Math.max(0, Math.min(normalizedPageCount - 1, currentPage))
    readonly property int itemSize: 28
    readonly property int pageItemMinWidth: 30
    readonly property int itemRadius: 8

    signal pageRequested(int page)

    function pageEntries(): var {
        const count = normalizedPageCount;
        const current = normalizedCurrentPage;
        const entries = [{
                type: "previous",
                page: previousPage()
            }];

        if (count <= Math.max(3, maxPageButtons)) {
            for (let page = 0; page < count; page++)
                entries.push({ type: "page", page });
        } else {
            let start = Math.max(1, current - 1);
            let end = Math.min(count - 2, current + 1);

            if (current <= 2) {
                start = 1;
                end = Math.min(count - 2, 4);
            } else if (current >= count - 3) {
                start = Math.max(1, count - 5);
                end = count - 2;
            }

            entries.push({ type: "page", page: 0 });

            if (start > 1)
                entries.push({ type: "ellipsis", page: -1 });

            for (let page = start; page <= end; page++)
                entries.push({ type: "page", page });

            if (end < count - 2)
                entries.push({ type: "ellipsis", page: -1 });

            entries.push({ type: "page", page: count - 1 });
        }

        entries.push({
            type: "next",
            page: nextPage()
        });

        return entries;
    }

    function previousPage(): int {
        if (wrap)
            return (normalizedCurrentPage - 1 + normalizedPageCount) % normalizedPageCount;
        return Math.max(0, normalizedCurrentPage - 1);
    }

    function nextPage(): int {
        if (wrap)
            return (normalizedCurrentPage + 1) % normalizedPageCount;
        return Math.min(normalizedPageCount - 1, normalizedCurrentPage + 1);
    }

    function itemLabel(entry: var): string {
        if (entry.type === "page")
            return String(entry.page + 1);
        if (entry.type === "ellipsis")
            return "...";
        return "";
    }

    function iconName(entry: var): string {
        if (entry.type === "previous")
            return "ui.chevron.left";
        if (entry.type === "next")
            return "ui.chevron.right";
        return "";
    }

    function canActivate(entry: var): bool {
        if (entry.type === "ellipsis")
            return false;
        if (entry.type === "page")
            return entry.page !== normalizedCurrentPage;
        return wrap || entry.page !== normalizedCurrentPage;
    }

    spacing: 4
    implicitHeight: itemSize

    // Pagination item repeater
    Repeater {
        model: root.pageEntries()

        // One page, ellipsis, or directional control
        Rectangle {
            id: itemRoot

            required property var modelData
            readonly property string itemType: String(modelData.type)
            readonly property bool current: itemType === "page" && modelData.page === root.normalizedCurrentPage
            readonly property bool interactive: root.enabled && root.canActivate(modelData)
            readonly property bool hovered: interactive && itemMouse.containsMouse
            readonly property bool dimmed: (itemType === "previous" || itemType === "next") && !interactive

            Layout.preferredWidth: root.pageItemMinWidth
            Layout.preferredHeight: root.itemSize
            radius: root.itemRadius
            color: hovered ? Colors.scrimSecondary : Colors.bgSecondary
            opacity: dimmed ? 0.42 : 1
            border.color: Colors.borderFaint
            border.width: 0.6

            // Directional chevron
            Text {
                visible: root.iconName(itemRoot.modelData).length > 0
                anchors.centerIn: parent
                text: visible ? Icons.glyph(root.iconName(itemRoot.modelData)) : ""
                color: itemRoot.hovered ? Colors.fgPrimary : Colors.fgSecondary
                font.family: Typography.iconFontFamily
                font.pixelSize: settings.iconPixelSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            // Page number or ellipsis label
            Text {
                visible: root.iconName(itemRoot.modelData).length === 0
                anchors.centerIn: parent
                text: root.itemLabel(itemRoot.modelData)
                color: itemRoot.current || itemRoot.hovered ? Colors.fgPrimary : Colors.fgSecondary
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            // Page click target
            MouseArea {
                id: itemMouse

                anchors.fill: parent
                enabled: itemRoot.interactive
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.pageRequested(itemRoot.modelData.page)
            }
        }
    }
}
