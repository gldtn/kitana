// Kitana managed Quickshell control

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

// Shared badge with Flux-style size, color, outline, icon, and rounded variants.
Rectangle {
    id: root

    Custom.Settings {
        id: settings
    }

    property string text: ""
    property string size: "sm"
    property string colorVariant: "subtle"
    property bool outline: false
    property bool rounded: false
    property string icon: ""
    property string trailingIcon: ""
    property int badgeHeight: defaultHeight()
    property int horizontalPadding: defaultHorizontalPadding()
    property int gap: defaultGap()
    property int fontPixelSize: defaultFontPixelSize()
    property int iconSize: defaultIconSize()
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
    clip: true

    function normalizedSize(): string {
        if (size === "xs" || size === "sm" || size === "md" || size === "lg")
            return size;
        return "sm";
    }

    function normalizedVariant(): string {
        if (colorVariant === "primary" || colorVariant === "secondary" || colorVariant === "tertiary" || colorVariant === "subtle" || colorVariant === "ghost" || colorVariant === "inverted" || colorVariant === "accent")
            return colorVariant;
        return "subtle";
    }

    function defaultHeight(): int {
        const value = normalizedSize();
        if (value === "xs")
            return 18;
        if (value === "md")
            return 30;
        if (value === "lg")
            return 36;
        return 24;
    }

    function defaultHorizontalPadding(): int {
        const value = normalizedSize();
        if (value === "xs")
            return 8;
        if (value === "md")
            return 14;
        if (value === "lg")
            return 16;
        return 10;
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
        return settings.textPixelSize - 1;
    }

    function defaultIconSize(): int {
        const value = normalizedSize();
        if (value === "xs")
            return 11;
        if (value === "md")
            return settings.iconPixelSize - 2;
        if (value === "lg")
            return settings.iconPixelSize;
        return settings.iconPixelSize - 4;
    }

    function defaultRadius(): int {
        const value = normalizedSize();
        if (value === "xs")
            return 5;
        if (value === "md")
            return 7;
        if (value === "lg")
            return 9;
        return 6;
    }

    function defaultBackgroundColor(): color {
        const value = normalizedVariant();
        if (outline || value === "ghost")
            return "transparent";
        if (value === "primary")
            return Colors.bgPrimary;
        if (value === "secondary")
            return Colors.bgSecondary;
        if (value === "tertiary")
            return Colors.bgTertiary;
        if (value === "inverted")
            return Colors.fgPrimary;
        if (value === "accent")
            return Colors.subtleAccent;
        return Colors.subtleSecondary;
    }

    function defaultForegroundColor(): color {
        const value = normalizedVariant();
        if (value === "inverted")
            return Colors.fgOnPrimary;
        if (value === "accent")
            return outline ? Colors.fgAccent : Colors.fgPrimary;
        return Colors.fgPrimary;
    }

    function defaultBorderColor(): color {
        const value = normalizedVariant();
        if (value === "ghost")
            return outline ? Colors.borderFaint : "transparent";
        if (value === "primary" || value === "secondary" || value === "tertiary" || value === "subtle")
            return Colors.borderFaint;
        if (value === "inverted")
            return Colors.borderHeavy;
        if (value === "accent")
            return Colors.borderAccent;
        return Colors.borderFaint;
    }

    function defaultBorderWidth(): real {
        return normalizedVariant() === "ghost" && !outline ? 0 : 1;
    }

    function defaultIconTone(): string {
        const value = normalizedVariant();
        if (value === "primary")
            return "primary";
        if (value === "inverted")
            return "inverse";
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
            Layout.preferredWidth: visible ? root.iconSize : 0
            Layout.preferredHeight: visible ? root.iconSize : 0
            name: root.icon.length > 0 ? root.icon : Icons.defaultIcon
            tone: root.iconTone
            size: root.iconSize
        }

        Text {
            visible: root.text.length > 0
            Layout.fillWidth: true
            text: root.text
            color: root.foregroundColor
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: Typography.fontFamily
            font.pixelSize: root.fontPixelSize
            font.weight: Font.DemiBold
        }

        Icon {
            visible: root.trailingIcon.length > 0
            Layout.preferredWidth: visible ? root.iconSize : 0
            Layout.preferredHeight: visible ? root.iconSize : 0
            name: root.trailingIcon.length > 0 ? root.trailingIcon : Icons.defaultIcon
            tone: root.iconTone
            size: root.iconSize
        }
    }
}
