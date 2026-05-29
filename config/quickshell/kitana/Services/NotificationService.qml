pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool doNotDisturb: false
    property var notifications: []
    property var popups: []
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
                id: nextId++,
                notification: notification,
                summary: notification.summary || "Notification",
                body: notification.body || "",
                appName: notification.appName || notification.desktopEntry || "app",
                appIcon: notification.appIcon || "",
                time: new Date(),
                urgency: notification.urgency
            };

            notifications = [item, ...notifications].slice(0, 50);
            if (!doNotDisturb)
                popups = [item, ...popups].slice(0, 4);
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
