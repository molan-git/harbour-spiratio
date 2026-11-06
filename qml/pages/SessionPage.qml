import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Window 2.0
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
        if (!soundOn())
            return
        var vol = Settings.value("volume", "50") / 100
        var s

        if (type === "in")
            s = Settings.value("soundIn", "bell1")
        else if (type === "out")
            s = Settings.value("soundOut", "bell2")
        else
            s = Settings.value("soundHold", "gong1")

        if (s === "bell1")       { bell1.volume = vol; bell1.play() }
        else if (s === "bell2")  { bell2.volume = vol; bell2.play() }
        else if (s === "gong2")  { gong2.volume = vol; gong2.play() }
        else                     { gong1.volume = vol; gong1.play() }
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

        // Top: page header
        Column {
            id: topCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            width: parent.width

            PageHeader {
                width: parent.width
                title: pattern ? Tr.trName(pattern.id) : qsTr("Spiratio")
                description: pattern ? "(" + pattern.tag + ") – " + Tr.trBenefit(pattern.id) : ""
            }
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
                        page.running = true
                        page.cueCurrent()
                    }
                }
            }
        }

        // BreathGraph fills remaining space, always square
        Item {
            id: graphArea
            anchors.top: topCol.bottom
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
