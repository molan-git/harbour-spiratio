import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property bool soundEnabled: Settings.value("soundEnabled", "true") === "true"

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader { title: "Settings" }

            TextSwitch {
                width: parent.width
                text: "Gong sound"
                description: "Play a gong when the session starts and whenever the breathing direction changes"
                checked: page.soundEnabled
                automaticCheck: true
                onCheckedChanged: {
                    if (checked !== page.soundEnabled) {
                        page.soundEnabled = checked
                        Settings.setValue("soundEnabled", checked ? "true" : "false")
                    }
                }
            }
        }
    }
}
