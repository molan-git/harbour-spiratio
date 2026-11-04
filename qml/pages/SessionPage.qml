import QtQuick 2.0
import Sailfish.Silica 1.0
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
    property bool running: false
    property bool finished: false
    readonly property bool isSession: true

    onStatusChanged: {
        if (status === PageStatus.Active && !finished && sessionElapsed === 0) {
            running = true
            cueCurrent()
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
        onTriggered: page.advance(interval / 1000)
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
        playCue("done")
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
        console.log("Spiratio cue:", type)
        if (!soundOn())
            return
        gong.stop()
        gong.play()
    }

    function phaseLabel(type) {
        if (type === "in")  return "Breathe in"
        if (type === "out") return "Breathe out"
        return "Hold"
    }

    function fmtTime(totalSeconds) {
        var s = Math.max(0, Math.round(totalSeconds))
        var m = Math.floor(s / 60)
        var r = s % 60
        return (m < 10 ? "0" + m : m) + ":" + (r < 10 ? "0" + r : r)
    }

    property string bigLabel: finished ? "Session complete"
                                       : (running ? phaseLabel(phases.length ? phases[phaseIndex].t : "hold")
                                                  : "Paused")
    property string bigCount: finished ? "" : (running ? "" + Math.ceil(phases.length ? phases[phaseIndex].s - phaseElapsed : 0) : "")
    property string timeLine: durationMinutes > 0
                              ? (finished ? "" : fmtTime(durationMinutes * 60 - sessionElapsed) + " left")
                              : fmtTime(sessionElapsed)

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: pattern ? pattern.name : "Spiratio"
                description: pattern ? "(" + pattern.tag + ") - " + pattern.benefit : ""
            }

            BreathGraph {
                id: graph
                width: parent.width - 2 * Theme.horizontalPageMargin
                height: width
                x: Theme.horizontalPageMargin
                phases: page.phases
                cycleTime: page.cycleTime
                timeInCycle: page.timeInCycle
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: page.bigLabel
                font.pixelSize: Theme.fontSizeHuge
                color: Theme.highlightColor
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: page.bigCount
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.highlightColor
                visible: text.length > 0
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: page.timeLine
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.secondaryHighlightColor
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                text: page.finished ? "Done"
                                    : (page.running ? "Pause" : (page.sessionElapsed > 0 ? "Resume" : "Start"))
                onClicked: {
                    if (page.finished) {
                        pageStack.pop()
                    } else if (page.running) {
                        page.running = false
                    } else {
                        page.running = true
                        page.cueCurrent()
                    }
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                text: "Stop session"
                visible: page.sessionElapsed > 0 && !page.finished
                onClicked: pageStack.pop()
            }
        }
    }
}
