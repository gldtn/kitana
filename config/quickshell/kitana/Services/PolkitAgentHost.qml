// Kitana managed Quickshell Polkit agent host

import QtQuick
import Quickshell.Services.Polkit

PolkitAgent {
    path: "/org/kitana/Polkit"

    onIsRegisteredChanged: {
        if (isRegistered)
            console.info("Kitana Polkit agent registered");
        else
            console.warn("Kitana Polkit agent is not registered");
    }
}
