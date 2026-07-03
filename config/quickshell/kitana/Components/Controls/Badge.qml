// Kitana managed Quickshell control

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

// Shared badge with size, color, border, icon, and rounded variants.
Rectangle {
    id: root

    Custom.Settings {
        id: settings
    }

    property string text: ""
    property string size: "sm"
    property string colorVariant: "subtle"
    property bool hasBorder: false
    property bool rounded: false
    property string icon: ""
    property string trailingIcon: ""
    property int badgeHeight: defaultHeight()
    property int horizontalPadding: defaultHorizontalPadding()
    property int gap: defaultGap()
    property int fontPixelSize: defaultFontPixelSize()
    property int iconSize: defaultIconSize()
    property real textVerticalOffset: defaultTextVerticalOffset()
    property real iconVerticalOffset: defaultIconVerticalOffset()
    property int cornerRadius: defaultRadius()
    property color backgroundColor: defaultBackgroundColor()
    property color foregroundColor: defaultForegroundColor()
    property color borderColor: defaultBorderColor()
    property real borderWidth: defaultBorderWidth()
    property string iconTone: defaultIconTone()

    implicitWidth: badgeContent.implicitWidth + horizontalPadding * 2
    implicitHeight: badgeHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    radius: rounded ? height / 2 : cornerRadius
    color: backgroundColor
    border.color: borderColor
    border.width: borderWidth
    border.pixelAligned: false
    antialiasing: true

    function normalizedSize(): string {
        if (size === "xs" || size === "sm" || size === "md" || size === "lg")
            return size;
        return "sm"; // defaults to small "sm" size
    }

    function normalizedVariant(): string {
        if (colorVariant === "primary" || colorVariant === "secondary" || colorVariant === "subtle" || colorVariant === "ghost" || colorVariant === "accent")
            return colorVariant;
        return "subtle";
    }

    function shouldDrawBorder(): bool {
        return hasBorder;
    }

    function defaultHeight(): int {
        const value = normalizedSize();
        if (value === "xs")
            return 18;
        if (value === "md")
            return 30;
        if (value === "lg")
            return 36;
        return 24; // small
    }

    function defaultHorizontalPadding(): int {
        const value = normalizedSize();
        if (value === "xs")
            return 8;
        if (value === "md")
            return 14;
        if (value === "lg")
            return 16;
        return 10; // smalll
    }

    function defaultGap(): int {
        return normalizedSize() === "xs" ? 5 : 7;
    }

    function defaultFontPixelSize(): int {
        const value = normalizedSize();
        if (value === "xs")
            return settings.textPixelSize - 2;
        if (value === "md")
            return settings.textPixelSize;
        if (value === "lg")
            return settings.textPixelSize + 1;
        return settings.textPixelSize - 1; // small
    }

    function defaultIconSize(): int {
        const value = normalizedSize();
        if (value === "xs")
            return 11;
        if (value === "md")
            return settings.iconPixelSize - 2;
        if (value === "lg")
            return settings.iconPixelSize;
        return settings.iconPixelSize - 4; // small
    }

    function defaultRadius(): int {
        const value = normalizedSize();
        if (value === "xs")
            return 5;
        if (value === "md")
            return 7;
        if (value === "lg")
            return 9;
        return 6; // small
    }

    function defaultTextVerticalOffset(): real {
        return normalizedSize() === "xs" ? 0.5 : 0;
    }

    function defaultIconVerticalOffset(): real {
        return normalizedSize() === "xs" ? -0.5 : 0;
    }

    function defaultBackgroundColor(): color {
        const value = normalizedVariant();
        if (value === "ghost")
            return "transparent";
        if (value === "primary")
            return Colors.bgTertiary;
        if (value === "secondary")
            return Colors.bgSecondary;
        if (value === "subtle")
            return Colors.mixColor(Colors.bgTertiary, Colors.bgPrimary, 0.45);
        if (value === "accent")
            return Colors.subtleAccent;
        return Colors.bgPrimary;
    }

    function defaultForegroundColor(): color {
        const value = normalizedVariant();
        if (value === "accent")
            return Colors.fgAccent;
        return Colors.mixColor(Colors.fgSecondary, Colors.fgAccent, 0.12);
    }

    function defaultBorderColor(): color {
        if (!shouldDrawBorder())
            return "transparent";
        return Colors.mixColor(Colors.borderLight, Colors.borderAccent, 0.12);
    }

    function defaultBorderWidth(): real {
        return shouldDrawBorder() ? 0.6 : 0;
    }

    function defaultIconTone(): string {
        const value = normalizedVariant();
        if (value === "primary")
            return "primary";
        if (value === "accent")
            return "accent";
        return "secondary";
    }

    RowLayout {
        id: badgeContent

        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        spacing: root.gap

        Icon {
            visible: root.icon.length > 0
            Layout.preferredWidth: visible ? implicitWidth : 0
            Layout.preferredHeight: visible ? root.iconSize : 0
            name: root.icon.length > 0 ? root.icon : Icons.defaultIcon
            tone: root.iconTone
            size: root.iconSize
            horizontalAlignment: Text.AlignLeft

            transform: Translate {
                y: root.iconVerticalOffset
            }
        }

        Text {
            visible: root.text.length > 0
            Layout.fillWidth: true
            text: root.text
            color: root.foregroundColor
            elide: Text.ElideRight
            horizontalAlignment: root.icon.length > 0 || root.trailingIcon.length > 0 ? Text.AlignLeft : Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: Typography.fontFamily
            font.pixelSize: root.fontPixelSize
            font.weight: Font.DemiBold

            transform: Translate {
                y: root.textVerticalOffset
            }
        }

        Icon {
            visible: root.trailingIcon.length > 0
            Layout.preferredWidth: visible ? implicitWidth : 0
            Layout.preferredHeight: visible ? root.iconSize : 0
            name: root.trailingIcon.length > 0 ? root.trailingIcon : Icons.defaultIcon
            tone: root.iconTone
            size: root.iconSize
            horizontalAlignment: Text.AlignLeft

            transform: Translate {
                y: root.iconVerticalOffset
            }
        }
    }
}
