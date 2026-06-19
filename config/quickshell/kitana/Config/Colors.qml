// Kitana managed Quickshell colors

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property string themePath: Quickshell.env("HOME") + "/.config/quickshell/kitana/Theme/current.json"
    readonly property string name: root.theme.slug ? root.theme.name : "Cyberdream"
    readonly property string mode: root.theme.slug ? root.theme.mode : "dark"
    readonly property bool dark: mode !== "light"
    readonly property var source: hasKeys(root.theme.colors) ? root.theme.colors : fallbackSource
    readonly property var mapping: hasKeys(root.theme.palette) ? root.theme.palette : fallbackMapping

    readonly property var fallbackSource: ({
        bg: "#16181a",
        bg_alt: "#1e2124",
        bg_highlight: "#3c4048",
        fg: "#ffffff",
        grey: "#7b8496",
        blue: "#5ea1ff",
        green: "#5eff6c",
        red: "#ff6e5e",
        yellow: "#f1ff5e",
        orange: "#ffbd5e"
    })

    readonly property var fallbackMapping: ({
        fgPrimary: "fg",
        fgSecondary: "grey",
        fgTertiary: "bg_highlight",
        fgOnPrimary: "bg",
        fgAccent: "orange",
        bgPrimary: "bg",
        bgSecondary: "bg_alt",
        bgTertiary: "bg_highlight",
        bgOnPrimary: "bg",
        bgAccent: "orange",
        borderDark: "bg",
        borderLight: "bg_highlight",
        borderFaint: "bg_alt",
        borderHeavy: "grey",
        borderAccent: "orange",
        info: "blue",
        success: "green",
        warning: "yellow",
        error: "red",
        scrimPrimary: { ref: "bg", alpha: 0.52 },
        scrimSecondary: { ref: "bg", alpha: 0.32 },
        scrimTertiary: { ref: "bg", alpha: 0.60 },
        subtleAccent: { ref: "orange", alpha: 0.16 },
        subtlePrimary: { ref: "bg", alpha: 0.16 },
        subtleSecondary: { ref: "bg_highlight", alpha: 0.65 },
        subtleTertiary: { ref: "grey", alpha: 0.50 }
    })

    function hasKeys(value: var): bool {
        return value && typeof value === "object" && Object.keys(value).length > 0;
    }

    function isHex(value: var): bool {
        return typeof value === "string" && /^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$/.test(value);
    }

    function hasOwn(value: var, key: string): bool {
        return value && typeof value === "object" && Object.prototype.hasOwnProperty.call(value, key);
    }

    function colorChannel(color: string): string {
        const value = String(color || "#000000");
        return value.startsWith("#") ? value.slice(-6) : value.slice(-6);
    }

    function clampRatio(value: real): real {
        return Math.max(0, Math.min(1, Number(value) || 0));
    }

    function colorPart(color: string, offset: int): int {
        return parseInt(colorChannel(color).slice(offset, offset + 2), 16);
    }

    function hexPart(value: real): string {
        return Math.max(0, Math.min(255, Math.round(value))).toString(16).padStart(2, "0");
    }

    function mixColor(from: string, to: string, ratio: real): string {
        const amount = clampRatio(ratio);
        const inverse = 1 - amount;
        return "#"
            + hexPart(colorPart(from, 0) * inverse + colorPart(to, 0) * amount)
            + hexPart(colorPart(from, 2) * inverse + colorPart(to, 2) * amount)
            + hexPart(colorPart(from, 4) * inverse + colorPart(to, 4) * amount);
    }

    function lighten(color: string, ratio: real): string {
        return mixColor(color, "#ffffff", ratio);
    }

    function darken(color: string, ratio: real): string {
        return mixColor(color, "#000000", ratio);
    }

    function alpha(color: string, opacity: real): string {
        const normalized = opacity > 1 ? opacity / 100 : opacity;
        const value = Math.max(0, Math.min(255, Math.round(255 * normalized)));
        return "#" + value.toString(16).padStart(2, "0") + colorChannel(color);
    }

    function resolveValue(value: var, fallback: string, seen: var): string {
        if (value && typeof value === "object") {
            const ref = value.ref || value.role || value.color || value.from;
            let base = resolveValue(ref, fallback, seen);
            if (value.mix !== undefined)
                base = mixColor(base, resolveValue(value.mix, fallback, seen), value.ratio !== undefined ? value.ratio : 0.5);
            if (value.lighten !== undefined)
                base = lighten(base, value.lighten);
            if (value.darken !== undefined)
                base = darken(base, value.darken);
            return value.alpha !== undefined ? alpha(base, value.alpha) : base;
        }

        if (isHex(value))
            return value;

        if (typeof value !== "string" || value.length === 0)
            return fallback;

        if (hasOwn(source, value)) {
            const sourceKey = "colors." + value;
            if (seen[sourceKey])
                return fallback;
            seen[sourceKey] = true;
            return resolveValue(source[value], fallback, seen);
        }

        if (hasOwn(mapping, value)) {
            const paletteKey = "palette." + value;
            if (seen[paletteKey])
                return fallback;
            seen[paletteKey] = true;
            return resolveValue(mapping[value], fallback, seen);
        }

        return fallback;
    }

    function resolve(role: string, fallback: string): string {
        return resolveValue(mapping[role], fallback || "#ff00ff", ({}));
    }

    function raw(name: string, fallback: string): string {
        return hasOwn(source, name) ? resolveValue(source[name], fallback || "#ff00ff", ({})) : (fallback || "#ff00ff");
    }

    function iconTone(tone: string, fallback: string): string {
        const icons = root.theme.icons || ({});
        const iconFallbacks = {
            primary: "fgPrimary",
            secondary: "fgSecondary",
            muted: "fgTertiary",
            subtle: "fgTertiary",
            accent: "fgAccent",
            onAccent: "fgOnPrimary",
            inverse: "bgOnPrimary",
            brand: "fgAccent",
            disabled: { ref: "fgTertiary", alpha: 0.5 },
            danger: "error"
        };
        return resolveValue(icons[tone] || iconFallbacks[tone], fallback, ({}));
    }

    // Runtime theme file watcher
    readonly property var theme: JsonAdapter {
        property string slug: "cyberdream"
        property string name: "Cyberdream"
        property string mode: "dark"
        property var colors: ({})
        property var palette: ({})
        property var icons: ({})
    }

    readonly property var themeFile: FileView {
        id: themeFileView

        path: root.themePath
        watchChanges: true
        printErrors: false
        onFileChanged: this.reload()
        adapter: root.theme
    }

    // Core semantic foreground roles
    readonly property color fgPrimary: resolve("fgPrimary", "#ffffff")
    readonly property color fgSecondary: resolve("fgSecondary", "#7b8496")
    readonly property color fgTertiary: resolve("fgTertiary", "#3c4048")
    readonly property color fgOnPrimary: resolve("fgOnPrimary", "#16181a")
    readonly property color fgAccent: resolve("fgAccent", "#ffbd5e")

    // Core semantic background roles
    readonly property color bgPrimary: resolve("bgPrimary", "#16181a")
    readonly property color bgSecondary: resolve("bgSecondary", "#1e2124")
    readonly property color bgTertiary: resolve("bgTertiary", "#3c4048")
    readonly property color bgOnPrimary: resolve("bgOnPrimary", "#16181a")
    readonly property color bgAccent: resolve("bgAccent", "#ffbd5e")

    // Core semantic border roles
    readonly property color borderDark: resolve("borderDark", "#16181a")
    readonly property color borderLight: resolve("borderLight", "#3c4048")
    readonly property color borderFaint: resolve("borderFaint", "#1e2124")
    readonly property color borderHeavy: resolve("borderHeavy", "#7b8496")
    readonly property color borderAccent: resolve("borderAccent", "#ffbd5e")

    // Status roles
    readonly property color info: resolve("info", "#5ea1ff")
    readonly property color success: resolve("success", "#5eff6c")
    readonly property color warning: resolve("warning", "#f1ff5e")
    readonly property color error: resolve("error", "#ff6e5e")

    // Overlay and low-emphasis roles
    readonly property color scrimPrimary: resolve("scrimPrimary", alpha(bgPrimary, 0.52))
    readonly property color scrimSecondary: resolve("scrimSecondary", alpha(bgPrimary, 0.32))
    readonly property color scrimTertiary: resolve("scrimTertiary", alpha(bgPrimary, 0.60))
    readonly property color subtleAccent: resolve("subtleAccent", alpha(bgAccent, 0.16))
    readonly property color subtlePrimary: resolve("subtlePrimary", alpha(bgPrimary, 0.16))
    readonly property color subtleSecondary: resolve("subtleSecondary", alpha(bgTertiary, 0.65))
    readonly property color subtleTertiary: resolve("subtleTertiary", alpha(fgTertiary, 0.50))

    // Icon tone roles used by Config/Icons.qml
    readonly property color iconPrimary: iconTone("primary", fgPrimary)
    readonly property color iconSecondary: iconTone("secondary", fgSecondary)
    readonly property color iconMuted: iconTone("muted", fgTertiary)
    readonly property color iconSubtle: iconTone("subtle", fgTertiary)
    readonly property color iconAccent: iconTone("accent", fgAccent)
    readonly property color iconOnAccent: iconTone("onAccent", fgOnPrimary)
    readonly property color iconInverse: iconTone("inverse", bgOnPrimary)
    readonly property color iconBrand: iconTone("brand", fgAccent)
    readonly property color iconDisabled: iconTone("disabled", alpha(fgTertiary, 0.50))
    readonly property color iconDanger: iconTone("danger", error)
}
