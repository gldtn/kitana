// Kitana managed Quickshell application search service

pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property var applications: []
    readonly property int maxResults: 12

    function refresh(): void {
        applications = DesktopEntries.applications.values.filter(app => isVisible(app));
    }

    function isVisible(app): bool {
        if (!app)
            return false;
        if (app.noDisplay === true || app.hidden === true)
            return false;
        const id = normalize(app.id || app.execString || app.exec);
        const name = normalize(app.name);
        const exec = normalize(app.execString || app.exec);
        const comment = normalize(app.comment);
        const hiddenText = [id, name, exec, comment].join(" ");

        if (name === "dropbox" || exec === "dropbox" || exec.startsWith("dropbox "))
            return false;
        if (name.indexOf("avahi") !== -1 && name.indexOf("browser") !== -1)
            return false;
        if (hiddenText.indexOf("avahi-discover") !== -1 || hiddenText.indexOf("/usr/bin/avahi-discover") !== -1)
            return false;
        return (app.name || "").length > 0;
    }

    function normalize(value): string {
        return (value || "").toString().toLowerCase();
    }

    function tokenize(value): var {
        return normalize(value).split(/[\s\-_\.]+/).filter(word => word.length > 0);
    }

    function wordBoundaryMatch(value, query): bool {
        const words = tokenize(value);
        const queryWords = tokenize(query);
        if (queryWords.length === 0)
            return false;

        for (let i = 0; i <= words.length - queryWords.length; i++) {
            let matched = true;
            for (let j = 0; j < queryWords.length; j++) {
                if (!words[i + j].startsWith(queryWords[j])) {
                    matched = false;
                    break;
                }
            }
            if (matched)
                return true;
        }
        return false;
    }

    function score(app, query): int {
        if (!query)
            return 1;

        const q = normalize(query).trim();
        const name = normalize(app.name);
        const genericName = normalize(app.genericName);
        const comment = normalize(app.comment);
        const id = normalize(app.id || app.execString || app.exec);
        const keywords = app.keywords || [];

        if (name === q)
            return 10000;
        if (name.startsWith(q))
            return 7000;
        if (wordBoundaryMatch(name, q))
            return 5000;
        if (name.indexOf(q) !== -1)
            return 3000;
        if (genericName.startsWith(q))
            return 1600;
        if (genericName.indexOf(q) !== -1)
            return 1200;
        if (id.indexOf(q) !== -1)
            return 900;
        for (const keyword of keywords) {
            const k = normalize(keyword);
            if (k.startsWith(q))
                return 800;
            if (k.indexOf(q) !== -1)
                return 500;
        }
        if (comment.indexOf(q) !== -1)
            return 250;

        let initials = "";
        for (const word of tokenize(name))
            initials += word.charAt(0);
        if (initials.startsWith(q))
            return 2000;

        return 0;
    }

    function search(query): var {
        const q = normalize(query).trim();
        const scored = [];

        for (const app of applications) {
            const appScore = score(app, q);
            if (appScore > 0) {
                scored.push({ app: app, score: appScore });
            }
        }

        scored.sort((a, b) => {
            if (b.score !== a.score)
                return b.score - a.score;
            return (a.app.name || "").localeCompare(b.app.name || "");
        });

        return scored.slice(0, maxResults).map(item => item.app);
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged(): void { root.refresh(); }
    }

    Component.onCompleted: refresh()
}
