import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import "../js/translations.js" as Tr
import "../components"

Page {
    id: page

    property var pattern: null
    property int durationMinutes: 10

    property var phases: pattern ? pattern.phases : []
    property var phaseStart: []
    property real cycleTime: 1
    property int phaseIndex: 0
    property real phaseElapsed: 0
    property real sessionElapsed: 0
    property real timeInCycle: 0
    property real lastTick: 0
    property bool running: false
    property bool finished: false
    readonly property bool isSession: true

    onStatusChanged: {
        if (status === PageStatus.Active && !finished && sessionElapsed === 0) {
            lastTick = 0
            running = true
            cueCurrent()
        } else if (status === PageStatus.Inactive) {
            // another page was pushed on top of us: stop ticking and cueing
            running = false
        }
    }

    Component.onCompleted: {
        var t = 0
        phaseStart = []
        if (phases.length === 0)
            return
        for (var i = 0; i < phases.length; i++) {
            phaseStart.push(t)
            t += phases[i].s
        }
        cycleTime = t
    }

    Timer {
        id: tick
        interval: 50
        repeat: true
        running: page.running && !page.finished
        onTriggered: {
            var now = Date.now()
            var dt = page.lastTick === 0 ? 0 : (now - page.lastTick) / 1000
            page.lastTick = now
            if (dt > 1) dt = 1   // cap: no cue bursts after long throttling
            page.advance(dt)
        }
    }

    function advance(dt) {
        sessionElapsed += dt

        if (durationMinutes > 0 && sessionElapsed >= durationMinutes * 60) {
            sessionElapsed = durationMinutes * 60
            finishSession()
            return
        }

        phaseElapsed += dt
        var dur = phases[phaseIndex].s
        while (phaseElapsed >= dur) {
            phaseElapsed -= dur
            phaseIndex = (phaseIndex + 1) % phases.length
            cue(phases[phaseIndex])
            dur = phases[phaseIndex].s
        }
        timeInCycle = phaseStart[phaseIndex] + phaseElapsed
    }

    function finishSession() {
        running = false
        finished = true
        playCue("done")   // "done" is intentionally silent in playCue for now
    }

    function cueCurrent() {
        if (phases.length > 0)
            cue(phases[phaseIndex])
    }

    function cue(phase) {
        playCue(phase.t)
    }

    function soundOn() {
        return Settings.value("soundEnabled", "true") === "true"
    }

    function playCue(type) {
        if (!soundOn())
            return
        var name
        if (type === "in")
            name = Settings.value("soundIn", "bell1")
        else if (type === "out")
            name = Settings.value("soundOut", "bell2")
        else if (type === "hold")
            name = Settings.value("soundHold", "gong1")
        else
            return   // "done": silent for now, or add a dedicated sound later

        var e = effectFor(name)
        if (e && e.status === SoundEffect.Ready) {
            e.volume = Settings.value("volume", "50") / 100
            e.play()
        }
    }

    function effectFor(name) {
        if (name === "bell1") return bell1
        if (name === "bell2") return bell2
        if (name === "gong1") return gong1
        if (name === "gong2") return gong2
        return null   // unknown name → silence instead of a "wrong" sound
    }

    function phaseLabel(type) {
        if (type === "in")  return qsTr("Breathe in")
        if (type === "out") return qsTr("Breathe out")
        return qsTr("Hold")
    }

    function fmtTime(totalSeconds) {
        var s = Math.max(0, Math.round(totalSeconds))
        var m = Math.floor(s / 60)
        var r = s % 60
        return (m < 10 ? "0" + m : m) + ":" + (r < 10 ? "0" + r : r)
    }

    property string bigLabel: finished ? qsTr("Session complete")
                                       : (running ? phaseLabel(phases.length ? phases[phaseIndex].t : "hold")
                                                  : qsTr("Paused"))
    property string bigCount: finished ? "" : ("" + Math.ceil(phases.length ? phases[phaseIndex].s - phaseElapsed : 0))
    property string timeLine: durationMinutes > 0
                              ? (finished ? "" : qsTr("%1 left").arg(fmtTime(durationMinutes * 60 - sessionElapsed)))
                              : fmtTime(sessionElapsed)

    SoundEffect {
        id: bell1
        source: "/usr/share/harbour-spiratio/sounds/bell1.wav"
    }
    SoundEffect {
        id: bell2
        source: "/usr/share/harbour-spiratio/sounds/bell2.wav"
    }
    SoundEffect {
        id: gong1
        source: "/usr/share/harbour-spiratio/sounds/gong1.wav"
    }
    SoundEffect {
        id: gong2
        source: "/usr/share/harbour-spiratio/sounds/gong2.wav"
    }

    Item {
        anchors.fill: parent

        PageHeader {
            id: header
            width: parent.width
            title: pattern ? Tr.trName(pattern.id) : qsTr("Spiratio")
            description: pattern ? "(" + pattern.tag + ") – " + Tr.trBenefit(pattern.id) : ""
        }

        // Bottom: labels + buttons
        Column {
            id: bottomCol
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            anchors.left: parent.left
            anchors.right: parent.right
            width: parent.width
            spacing: Theme.paddingMedium

            // Breath step indicator
            Label {
                width: parent.width
                height: Theme.fontSizeHuge * 1.4
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                text: page.bigLabel
                font.pixelSize: Theme.fontSizeHuge
                color: Theme.highlightColor
            }

            // Breath step timer
            Label {
                width: parent.width
                height: Theme.fontSizeHuge * 1.4
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                text: page.bigCount
                font.pixelSize: Theme.fontSizeHuge
                color: Theme.highlightColor
                visible: text.length > 0
            }

            // Remaining Time
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: page.timeLine
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.secondaryHighlightColor
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Button {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: page.finished ? qsTr("Done")
                                    : (page.running ? qsTr("Pause") : (page.sessionElapsed > 0 ? qsTr("Resume") : qsTr("Start")))
                onClicked: {
                    if (page.finished) {
                        pageStack.pop()
                    } else if (page.running) {
                        page.running = false
                    } else {
                        page.lastTick = 0
                        page.running = true
                        if (page.phaseElapsed === 0)
                            page.cueCurrent()   // only cue if at the start of a phase
                    }
                }
            }
        }

        // BreathGraph fills remaining space
        Item {
            id: graphArea
            anchors.top: header.bottom
            anchors.bottom: bottomCol.top
            anchors.left: parent.left
            anchors.right: parent.right

            BreathGraph {
                id: graph
                anchors.fill: parent
                phases: page.phases
                cycleTime: page.cycleTime
                timeInCycle: page.timeInCycle
            }
        }
    }
}
