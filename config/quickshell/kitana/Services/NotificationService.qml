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

    function linkify(value): string {
        return escapeMarkup(value).replace(/(https?:\/\/[^\s<]+)/g, '<a href="$1">$1</a>');
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

            const item = {
                id: root.nextId++,
                notification: notification,
                summary: notification.summary || "Notification",
                body: notification.body || "",
                bodyMarkup: root.linkify(notification.body || ""),
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
