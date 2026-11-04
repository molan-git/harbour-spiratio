import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

CoverBackground {
    id: cover

    property var session: (pageStack && pageStack.currentPage
                           && pageStack.currentPage.isSession)
                          ? pageStack.currentPage : null

    Column {
        anchors.centerIn: parent
        spacing: Theme.paddingMedium
        width: parent.width - 2 * Theme.paddingLarge

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Spiratio"
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeLarge
        }

        BreathGraph {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.7
            height: width
            visible: cover.session !== null && cover.session.phases.length > 0
            phases: cover.session ? cover.session.phases : []
            cycleTime: cover.session ? cover.session.cycleTime : 1
            timeInCycle: cover.session ? cover.session.timeInCycle : 0
            lineColor: Theme.secondaryColor
            dotColor: Theme.primaryColor
            lineThickness: 4
            dotRadius: Theme.paddingSmall
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: cover.session !== null && cover.session.pattern !== null
            text: cover.session && cover.session.pattern ? cover.session.pattern.tag : ""
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeMedium
            elide: Text.ElideRight
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }
    }

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
