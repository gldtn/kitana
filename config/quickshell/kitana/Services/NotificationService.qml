// Kitana managed Quickshell service

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import ".."

Singleton {
    id: root

    property bool doNotDisturb: false
    property var notifications: []
    property var popups: []
    property var collapsedGroups: ({})
    property int nextId: 1
    readonly property int count: notifications.length

    function dismiss(item) {
        if (!item)
            return;
        try {
            if (item.notification && typeof item.notification.dismiss === "function")
                item.notification.dismiss();
        } catch (e) {}
        notifications = notifications.filter(entry => entry && entry.id !== item.id);
        popups = popups.filter(entry => entry && entry.id !== item.id);
    }

    function dismissLast() {
        dismiss(notifications[0]);
    }

    function clear() {
        for (const item of notifications) {
            try {
                if (item && item.notification && typeof item.notification.dismiss === "function")
                    item.notification.dismiss();
            } catch (e) {}
        }
        notifications = [];
        popups = [];
    }

    function toggleDoNotDisturb() {
        doNotDisturb = !doNotDisturb;
    }

    function groupKey(appName: string): string {
        return appName || "app";
    }

    function isGroupCollapsed(appName: string): bool {
        return collapsedGroups[groupKey(appName)] !== false;
    }

    function toggleGroup(appName: string): void {
        const key = groupKey(appName);
        const nextGroups = {};

        for (const existingKey in collapsedGroups)
            nextGroups[existingKey] = collapsedGroups[existingKey];

        if (isGroupCollapsed(appName))
            nextGroups[key] = false;
        else
            delete nextGroups[key];

        collapsedGroups = nextGroups;
    }

    function appCount(appName: string): int {
        let total = 0;
        for (const item of notifications) {
            if (item && item.appName === appName)
                total++;
        }
        return total;
    }

    function visibleNotifications(): var {
        const counts = {};
        const seen = {};
        const visible = [];

        for (const item of notifications) {
            if (!item)
                continue;
            const key = groupKey(item.appName);
            counts[key] = (counts[key] || 0) + 1;
        }

        for (const item of notifications) {
            if (!item)
                continue;

            const key = groupKey(item.appName);
            const count = counts[key] || 1;
            const header = !seen[key];
            const collapsed = count > 1 && isGroupCollapsed(item.appName);

            if (collapsed && !header)
                continue;

            seen[key] = true;
            visible.push({
                item: item,
                count: count,
                expandable: count > 1,
                collapsed: collapsed,
                header: header,
            });
        }

        return visible;
    }

    function visibleNotificationGroups(): var {
        const groups = [];
        const byKey = {};

        for (const item of notifications) {
            if (!item)
                continue;

            const key = groupKey(item.appName);
            if (!byKey[key]) {
                byKey[key] = {
                    appName: item.appName,
                    item: item,
                    items: [],
                };
                groups.push(byKey[key]);
            }

            byKey[key].items.push(item);
        }

        return groups.map(group => {
            const count = group.items.length;
            const collapsed = count > 1 && isGroupCollapsed(group.appName);
            return {
                appName: group.appName,
                item: group.item,
                items: collapsed ? [group.item] : group.items,
                count: count,
                expandable: count > 1,
                collapsed: collapsed,
            };
        });
    }

    function timeAgo(time): string {
        if (!time)
            return "now";

        const seconds = Math.max(0, Math.floor((Date.now() - time.getTime()) / 1000));
        if (seconds < 60)
            return "now";
        const minutes = Math.floor(seconds / 60);
        if (minutes < 60)
            return minutes + "m";
        const hours = Math.floor(minutes / 60);
        if (hours < 24)
            return hours + "h";
        return Math.floor(hours / 24) + "d";
    }

    function escapeMarkup(value): string {
        return (value || "")
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;");
    }

    function decodeEntities(value): string {
        return (value || "")
            .replace(/&nbsp;/gi, " ")
            .replace(/&amp;/gi, "&")
            .replace(/&lt;/gi, "<")
            .replace(/&gt;/gi, ">")
            .replace(/&quot;/gi, "\"")
            .replace(/&apos;/gi, "'")
            .replace(/&#39;/g, "'")
            .replace(/&#(\d+);/g, function(match, code) {
                const character = parseInt(code, 10);
                return isNaN(character) ? match : String.fromCharCode(character);
            })
            .replace(/&#x([0-9a-f]+);/gi, function(match, code) {
                const character = parseInt(code, 16);
                return isNaN(character) ? match : String.fromCharCode(character);
            });
    }

    function cleanText(value): string {
        let text = (value || "").toString();
        text = text.replace(/<\s*br\s*\/?\s*>/gi, "\n");
        text = text.replace(/<\s*\/\s*(p|div|li|h[1-6])\s*>/gi, "\n");
        text = text.replace(/<\s*a\b[^>]*>([\s\S]*?)<\s*\/\s*a\s*>/gi, function(match, label) {
            return root.cleanText(label);
        });
        text = text.replace(/<[^>]+>/g, "");
        text = decodeEntities(text).replace(/\r/g, "");
        text = text.replace(/[ \t]+\n/g, "\n").replace(/\n[ \t]+/g, "\n");
        text = text.replace(/[ \t]{2,}/g, " ").replace(/\n{3,}/g, "\n\n");
        return text.trim();
    }

    function anchorHref(attributes): string {
        const match = (attributes || "").match(/\bhref\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))/i);
        return match ? (match[1] || match[2] || match[3] || "") : "";
    }

    function safeLinkTarget(value): string {
        const link = decodeEntities(value || "").trim();
        return /^(https?:\/\/|mailto:)/i.test(link) ? link : "";
    }

    function linkifyEscapedText(value): string {
        return (value || "").replace(/\bhttps?:\/\/[^\s<]+/g, function(url) {
            let link = url;
            let suffix = "";

            while (/[),.!?;:]$/.test(link)) {
                suffix = link.charAt(link.length - 1) + suffix;
                link = link.slice(0, -1);
            }

            if (link.length === 0)
                return url;

            return '<a href="' + escapeMarkup(link) + '">' + link + '</a>' + suffix;
        });
    }

    function bodyMarkup(value): string {
        const anchors = [];
        let text = (value || "").toString();

        text = text.replace(/<\s*a\b([^>]*)>([\s\S]*?)<\s*\/\s*a\s*>/gi, function(match, attributes, label) {
            const href = safeLinkTarget(anchorHref(attributes));
            const labelText = cleanText(label) || href;

            if (href.length === 0)
                return labelText;

            const token = "\ue000" + anchors.length + "\ue001";
            anchors.push({ href: href, label: labelText });
            return token;
        });

        let richText = linkifyEscapedText(escapeMarkup(cleanText(text))).replace(/\n/g, "<br/>");

        for (let index = 0; index < anchors.length; index++) {
            const token = "\ue000" + index + "\ue001";
            const anchor = '<a href="' + escapeMarkup(anchors[index].href) + '">' + escapeMarkup(anchors[index].label) + '</a>';
            richText = richText.split(token).join(anchor);
        }

        return richText;
    }

    function bodyShouldCollapse(value): bool {
        return bodyExcerpt(value) !== (value || "");
    }

    function bodyExcerpt(value): string {
        const text = value || "";
        const limit = 180;
        const lines = text.split("\n");
        let excerpt = lines.slice(0, 2).join("\n");

        if (excerpt.length > limit) {
            excerpt = excerpt.slice(0, limit);
            const lastSpace = excerpt.lastIndexOf(" ");
            if (lastSpace > 80)
                excerpt = excerpt.slice(0, lastSpace);
        }

        excerpt = excerpt.trim();
        return excerpt === text ? text : excerpt + "...";
    }

    function tone(item): string {
        const text = [item && item.urgency, item && item.category, item && item.summary, item && item.body]
            .join(" ")
            .toLowerCase();

        if (item && item.urgency === 2 || /critical|error|failed|failure|danger|urgent/.test(text))
            return "critical";
        if (/warn|warning|caution/.test(text))
            return "warning";
        if (/success|successful|complete|completed|done|saved/.test(text))
            return "success";
        return "info";
    }

    function toneForeground(item): color {
        const nextTone = tone(item);
        if (nextTone === "critical")
            return Colors.error;
        if (nextTone === "warning")
            return Colors.warning;
        if (nextTone === "success")
            return Colors.success;
        return Colors.info;
    }

    function toneBackground(item): color {
        const nextTone = tone(item);
        if (nextTone === "critical")
            return Colors.alpha(Colors.error, 0.2);
        if (nextTone === "warning")
            return Colors.alpha(Colors.warning, 0.2);
        if (nextTone === "success")
            return Colors.alpha(Colors.success, 0.2);
        return Colors.alpha(Colors.info, 0.2);
    }

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        actionIconsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        bodyImagesSupported: true
        persistenceSupported: true

        onNotification: notification => {
            notification.tracked = true;
            const bodyText = root.cleanText(notification.body || "");
            const summaryText = root.cleanText(notification.summary || "Notification") || "Notification";

            const item = {
                id: root.nextId++,
                notification: notification,
                summary: summaryText,
                body: bodyText,
                bodyMarkup: root.bodyMarkup(notification.body || ""),
                bodyPreviewMarkup: root.bodyMarkup(root.bodyExcerpt(bodyText)),
                bodyExpandable: root.bodyShouldCollapse(bodyText),
                appName: notification.appName || notification.desktopEntry || "app",
                appIcon: notification.appIcon || "",
                category: "",
                time: new Date(),
                urgency: notification.urgency
            };

            root.notifications = [item, ...root.notifications].slice(0, 50);
            if (!root.doNotDisturb)
                root.popups = [item, ...root.popups].slice(0, 4);
        }
    }

    Timer {
        interval: 500
        running: root.popups.length > 0
        repeat: true
        onTriggered: {
            const now = Date.now();
            root.popups = root.popups.filter(item => item && (now - item.time.getTime()) < 5000);
        }
    }
}
