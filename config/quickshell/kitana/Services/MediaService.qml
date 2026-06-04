pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values || []
    readonly property var activePlayer: preferredPlayer()
    readonly property bool available: activePlayer !== null
    readonly property bool playing: available && activePlayer.isPlaying
    readonly property string status: !available ? "Stopped" : (playing ? "Playing" : "Paused")
    readonly property string playerName: available ? (activePlayer.identity || activePlayer.desktopEntry || "Media") : "Media"
    readonly property string title: available ? (activePlayer.trackTitle || "Unknown Track") : "Nothing Playing"
    readonly property string artist: available ? (activePlayer.trackArtist || "Unknown Artist") : ""
    readonly property string album: available ? (activePlayer.trackAlbum || "") : ""
    readonly property string artUrl: available ? (activePlayer.trackArtUrl || "") : ""
    readonly property bool canPrevious: available && activePlayer.canGoPrevious
    readonly property bool canNext: available && activePlayer.canGoNext
    readonly property bool canStop: available && activePlayer.canControl
    readonly property bool canTogglePlaying: available && activePlayer.canTogglePlaying

    function preferredPlayer(): var {
        const items = players;
        for (const player of items) {
            if (player && player.isPlaying)
                return player;
        }
        for (const player of items) {
            if (player)
                return player;
        }
        return null;
    }

    function artSource(): string {
        if (!artUrl)
            return "";
        return artUrl.indexOf("file://") === 0 || artUrl.indexOf("http") === 0 ? artUrl : "file://" + artUrl;
    }

    function previous(): void {
        if (canPrevious)
            activePlayer.previous();
    }

    function playPause(): void {
        if (canTogglePlaying)
            activePlayer.togglePlaying();
    }

    function stop(): void {
        if (canStop)
            activePlayer.stop();
    }

    function next(): void {
        if (canNext)
            activePlayer.next();
    }
}
