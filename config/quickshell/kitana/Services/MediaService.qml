// Kitana managed Quickshell service

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values || []
    readonly property var activePlayer: preferredPlayer()
    readonly property real maxTrackLength: 24 * 60 * 60
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
    readonly property bool canSeek: available && activePlayer.canSeek && activePlayer.positionSupported
    readonly property bool hasProgress: available && activePlayer.lengthSupported && saneDuration(activePlayer.length)
    readonly property real position: available && activePlayer.positionSupported ? activePlayer.position : 0
    readonly property real length: hasProgress ? activePlayer.length : 0
    readonly property real progress: hasProgress ? clamp(position / length, 0, 1) : 0
    readonly property string positionLabel: hasProgress ? formatTime(clamp(position, 0, length)) : "0:00"
    readonly property string lengthLabel: hasProgress ? formatTime(length) : "0:00"
    readonly property bool shuffleSupported: available && activePlayer.canControl && activePlayer.shuffleSupported
    readonly property bool shuffle: shuffleSupported && activePlayer.shuffle
    readonly property bool loopSupported: available && activePlayer.canControl && activePlayer.loopSupported
    readonly property int loopState: available ? activePlayer.loopState : MprisLoopState.None
    readonly property bool looping: loopSupported && loopState !== MprisLoopState.None
    readonly property string loopLabel: !loopSupported ? "Repeat" : (loopState === MprisLoopState.Track ? "Repeat 1" : (loopState === MprisLoopState.Playlist ? "Repeat all" : "Repeat off"))

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

    function clamp(value: real, minimum: real, maximum: real): real {
        if (value !== value)
            return minimum;
        return Math.max(minimum, Math.min(maximum, value));
    }

    function saneDuration(seconds: real): bool {
        return seconds > 0 && seconds === seconds && seconds <= maxTrackLength;
    }

    function formatTime(seconds: real): string {
        if (!available || !saneDuration(seconds))
            return "0:00";

        const total = Math.floor(seconds);
        const minutes = Math.floor(total / 60);
        const remainder = total % 60;
        return minutes + ":" + String(remainder).padStart(2, "0");
    }

    function refreshPosition(): void {
        if (available && activePlayer.positionSupported)
            activePlayer.positionChanged();
    }

    function setPosition(ratio: real): void {
        if (!canSeek || !hasProgress)
            return;

        activePlayer.position = clamp(ratio, 0, 1) * length;
        refreshPosition();
    }

    function toggleShuffle(): void {
        if (shuffleSupported)
            activePlayer.shuffle = !activePlayer.shuffle;
    }

    function cycleLoop(): void {
        if (!loopSupported)
            return;

        if (activePlayer.loopState === MprisLoopState.None)
            activePlayer.loopState = MprisLoopState.Playlist;
        else if (activePlayer.loopState === MprisLoopState.Playlist)
            activePlayer.loopState = MprisLoopState.Track;
        else
            activePlayer.loopState = MprisLoopState.None;
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
