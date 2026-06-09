// Kitana managed Quickshell application search service

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var applications: []
    property var usage: ({})
    readonly property int maxSearchResults: 14
    readonly property int maxBrowseResults: 60
    readonly property string kitanaDir: Quickshell.env("KITANA_DIR") || Quickshell.env("HOME") + "/.local/share/kitana"
    readonly property string usagePath: (Quickshell.env("HOME") || "") + "/.local/state/kitana/quickshell-launcher-usage.json"

    function refresh(): void {
        applications = DesktopEntries.applications.values.filter(app => isVisible(app));
    }

    function loadUsage(): void {
        try {
            const text = usageFile.text().trim();
            usage = text.length > 0 ? JSON.parse(text) : ({});
        } catch (error) {
            usage = ({});
        }
    }

    function saveUsage(): void {
        try {
            usageFile.setText(JSON.stringify(usage));
        } catch (error) {
        }
    }

    function recordLaunch(item): void {
        if (!item || !item.usageKey)
            return;

        const copy = Object.assign({}, usage);
        const existing = copy[item.usageKey] || { count: 0, last: 0 };
        copy[item.usageKey] = { count: existing.count + 1, last: Date.now() };
        usage = copy;
        saveUsage();
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

    function textScore(text, query): int {
        if (!query)
            return 1;

        const q = normalize(query).trim();
        const value = normalize(text);
        if (value === q)
            return 9000;
        if (value.startsWith(q))
            return 6000;
        if (wordBoundaryMatch(value, q))
            return 4500;
        if (value.indexOf(q) !== -1)
            return 2400;
        return 0;
    }

    function appUsageKey(app): string {
        return "app:" + (app.id || app.execString || app.name || "unknown");
    }

    function actionUsageKey(app, action): string {
        return "action:" + (app.id || app.name || "unknown") + ":" + (action.id || action.name || action.execString || "unknown");
    }

    function frecencyBoost(usageKey): int {
        const item = usage[usageKey];
        if (!item)
            return 0;

        const countBoost = Math.min((item.count || 0) * 70, 700);
        const ageHours = Math.max(0, (Date.now() - (item.last || 0)) / 3600000);
        const recencyBoost = Math.max(0, Math.round(360 - ageHours * 3));
        return countBoost + recencyBoost;
    }

    function appItem(app, appScore): var {
        const usageKey = appUsageKey(app);
        return {
            type: "app",
            name: app.name || "Application",
            subtitle: app.comment || app.genericName || app.id || "Application",
            icon: app.icon || "application-x-executable",
            app: app,
            usageKey: usageKey,
            score: appScore + frecencyBoost(usageKey),
            hint: "Enter"
        };
    }

    function appActionItems(app, query, appScore): var {
        if (!query || !app.actions)
            return [];

        const items = [];
        for (const action of app.actions) {
            if (!action || !(action.name || action.id))
                continue;

            const actionScore = Math.max(textScore(action.name, query), textScore((app.name || "") + " " + (action.name || ""), query));
            if (actionScore <= 0 && appScore < 5000)
                continue;

            const usageKey = actionUsageKey(app, action);
            items.push({
                type: "action",
                name: action.name || "App action",
                subtitle: (app.name || "Application") + " action",
                icon: action.icon || app.icon || "application-x-executable",
                app: app,
                action: action,
                usageKey: usageKey,
                score: Math.max(actionScore, Math.max(0, appScore - 400)) + frecencyBoost(usageKey),
                hint: "Run"
            });
        }
        return items;
    }

    function sessionItems(query): var {
        if (!query)
            return [];

        const actions = [
            { name: "Lock", subtitle: "Lock this session", icon: "system-lock-screen", fallbackIcon: "󰌾", terms: "lock screen session secure", command: [kitanaDir + "/bin/kitana-lock"] },
            { name: "Log out", subtitle: "End this Hyprland session", icon: "system-log-out", fallbackIcon: "󰗽", terms: "logout log out exit session hyprland", command: ["hyprctl", "dispatch", "exit"] },
            { name: "Restart", subtitle: "Reboot this computer", icon: "system-reboot", fallbackIcon: "󰜉", terms: "restart reboot system", command: ["systemctl", "reboot"] },
            { name: "Shut down", subtitle: "Power off this computer", icon: "system-shutdown", fallbackIcon: "󰐥", terms: "shutdown shut down power off poweroff", command: ["systemctl", "poweroff"] }
        ];

        const items = [];
        for (const action of actions) {
            const actionScore = textScore(action.name + " " + action.terms, query);
            if (actionScore <= 0)
                continue;

            const usageKey = "session:" + normalize(action.name).replace(/\s+/g, "-");
            items.push(Object.assign({}, action, {
                type: "session",
                usageKey: usageKey,
                score: actionScore + 1200 + frecencyBoost(usageKey),
                hint: "Run"
            }));
        }
        return items;
    }

    function evaluateExpression(expression): var {
        const tokens = [];
        let index = 0;
        while (index < expression.length) {
            const char = expression.charAt(index);
            if (/\s/.test(char)) {
                index++;
                continue;
            }
            if (/[0-9.]/.test(char)) {
                let end = index + 1;
                while (end < expression.length && /[0-9.]/.test(expression.charAt(end)))
                    end++;
                const text = expression.slice(index, end);
                if (!/^\d+(\.\d*)?$|^\.\d+$/.test(text))
                    throw new Error("Invalid number");
                tokens.push({ type: "number", value: parseFloat(text) });
                index = end;
                continue;
            }
            if ("+-*/%()".indexOf(char) !== -1) {
                tokens.push({ type: char });
                index++;
                continue;
            }
            throw new Error("Invalid character");
        }

        let position = 0;
        function peek() { return tokens[position] || null; }
        function take(type) {
            if (peek() && peek().type === type) {
                position++;
                return true;
            }
            return false;
        }
        function parseFactor() {
            if (take("+"))
                return parseFactor();
            if (take("-"))
                return -parseFactor();
            if (take("(")) {
                const nested = parseExpression();
                if (!take(")"))
                    throw new Error("Missing closing parenthesis");
                return nested;
            }
            const token = peek();
            if (!token || token.type !== "number")
                throw new Error("Expected number");
            position++;
            return token.value;
        }
        function parseTerm() {
            let value = parseFactor();
            while (peek() && "*/%".indexOf(peek().type) !== -1) {
                const operator = peek().type;
                position++;
                const right = parseFactor();
                if (operator === "*")
                    value *= right;
                else if (operator === "/")
                    value /= right;
                else
                    value %= right;
            }
            return value;
        }
        function parseExpression() {
            let value = parseTerm();
            while (peek() && "+-".indexOf(peek().type) !== -1) {
                const operator = peek().type;
                position++;
                const right = parseTerm();
                value = operator === "+" ? value + right : value - right;
            }
            return value;
        }

        const result = parseExpression();
        if (position !== tokens.length)
            throw new Error("Unexpected token");
        return result;
    }

    function calculatorItem(query): var {
        const raw = (query || "").trim();
        const expression = raw.startsWith("=") ? raw.slice(1).trim() : raw;
        if (expression.length === 0 || expression.length > 80)
            return null;
        if (!/[0-9]/.test(expression) || !/[+\-*\/%]/.test(expression))
            return null;
        if (!/^[0-9+\-*\/%().\s]+$/.test(expression))
            return null;

        try {
            const value = evaluateExpression(expression);
            if (typeof value !== "number" || !isFinite(value))
                return null;
            const result = Math.round(value * 100000000) / 100000000;
            return {
                type: "calculator",
                name: expression + " = " + result,
                subtitle: "Copy calculator result",
                icon: "accessories-calculator",
                fallbackIcon: "󰃬",
                value: result.toString(),
                score: 12000,
                hint: "Copy"
            };
        } catch (error) {
            return null;
        }
    }

    function search(query): var {
        const q = normalize(query).trim();
        const scored = [];

        const calculator = calculatorItem(query);
        if (calculator)
            scored.push(calculator);

        for (const item of sessionItems(q))
            scored.push(item);

        for (const app of applications) {
            const appScore = score(app, q);
            if (appScore > 0) {
                scored.push(appItem(app, appScore));
                for (const actionItem of appActionItems(app, q, appScore))
                    scored.push(actionItem);
            }
        }

        scored.sort((a, b) => {
            if (b.score !== a.score)
                return b.score - a.score;
            return (a.name || "").localeCompare(b.name || "");
        });

        return scored.slice(0, q ? maxSearchResults : maxBrowseResults);
    }

    FileView {
        id: usageFile
        path: root.usagePath
        printErrors: false
        onLoaded: root.loadUsage()
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged(): void { root.refresh(); }
    }

    Component.onCompleted: refresh()
}
