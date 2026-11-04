import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

CoverBackground {
    id: cover

    // The live session page, if one is running (SessionPage sets isSession: true)
    property var session: (pageStack && pageStack.currentPage
                           && pageStack.currentPage.isSession)
                          ? pageStack.currentPage : null

    // Fallback: app name when no session is active
    Label {
        visible: cover.session === null
        anchors.centerIn: parent
        text: "Spiratio"
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeLarge
    }

    // Pattern tag, e.g. "4-4-4-4" — guidelines: left/right paddingLarge, top paddingMedium
    Label {
        id: tagLabel
        visible: cover.session !== null
        x: Theme.paddingLarge
        y: Theme.paddingMedium
        width: parent.width - 2 * Theme.paddingLarge
        text: cover.session && cover.session.pattern ? cover.session.pattern.tag : ""
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeMedium
        elide: Text.ElideRight
    }

    // The breathing graph, in primary colors:
    // line with reduced opacity so it is distinguishable from the solid moving dot
    BreathGraph {
        id: graph
        visible: cover.session !== null
        anchors {
            top: tagLabel.bottom
            topMargin: Theme.paddingMedium
            left: parent.left
            leftMargin: Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.paddingLarge
        }
        height: width

        phases: cover.session ? cover.session.phases : []
        cycleTime: cover.session ? cover.session.cycleTime : 1
        timeInCycle: cover.session ? cover.session.timeInCycle : 0

        lineColor: Theme.rgba(Theme.primaryColor.r,
                              Theme.primaryColor.g,
                              Theme.primaryColor.b, 0.6)
        dotColor: Theme.primaryColor
        lineThickness: 4
        dotRadius: Theme.paddingSmall
    }

    // Play / pause button — only visible while a session is active
    CoverActionList {
        enabled: cover.session !== null
        CoverAction {
            iconSource: (cover.session && cover.session.running)
                         ? "image://theme/icon-cover-pause"
                         : "image://theme/icon-cover-play"
            onTriggered: {
                if (cover.session)
                    cover.session.running = !cover.session.running
            }
        }
    }
}
