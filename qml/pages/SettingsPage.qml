import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    // sound file names shown in the combos, index matches the menu items
    property var soundNames: ["bell1", "bell2", "gong1", "gong2"]

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader { title: qsTr("Settings") }

            SectionHeader { text: qsTr("Sounds") }

            TextSwitch {
                id: soundSwitch
                width: parent.width
                text: qsTr("Sound")
                description: qsTr("Play a sound when the breathing direction changes")
                automaticCheck: false
                onClicked: checked = !checked
                onCheckedChanged: {
                    Settings.setValue("soundEnabled", checked ? "true" : "false")
                }
                Component.onCompleted: {
                    checked = Settings.value("soundEnabled", "true") === "true"
                }
            }

            ComboBox {
                id: inCombo
                width: parent.width
                label: qsTr("Breath in")
                currentIndex: -1
                menu: ContextMenu {
                    MenuItem { text: "Bell 1" }
                    MenuItem { text: "Bell 2" }
                    MenuItem { text: "Gong 1" }
                    MenuItem { text: "Gong 2" }
                }
                onCurrentIndexChanged: {
                    if (currentIndex < 0)
                        return
                    Settings.setValue("soundIn", page.soundNames[currentIndex])
                }
                Component.onCompleted: {
                    var idx = page.soundNames.indexOf(Settings.value("soundIn", "bell1"))
                    currentIndex = (idx >= 0) ? idx : 0
                }
            }

            ComboBox {
                id: outCombo
                width: parent.width
                label: qsTr("Breath out")
                currentIndex: -1
                menu: ContextMenu {
                    MenuItem { text: "Bell 1" }
                    MenuItem { text: "Bell 2" }
                    MenuItem { text: "Gong 1" }
                    MenuItem { text: "Gong 2" }
                }
                onCurrentIndexChanged: {
                    if (currentIndex < 0)
                        return
                    Settings.setValue("soundOut", page.soundNames[currentIndex])
                }
                Component.onCompleted: {
                    var idx = page.soundNames.indexOf(Settings.value("soundOut", "bell2"))
                    currentIndex = (idx >= 0) ? idx : 1
                }
            }

            ComboBox {
                id: holdCombo
                width: parent.width
                label: qsTr("Hold")
                currentIndex: -1
                menu: ContextMenu {
                    MenuItem { text: "Bell 1" }
                    MenuItem { text: "Bell 2" }
                    MenuItem { text: "Gong 1" }
                    MenuItem { text: "Gong 2" }
                }
                onCurrentIndexChanged: {
                    if (currentIndex < 0)
                        return
                    Settings.setValue("soundHold", page.soundNames[currentIndex])
                }
                Component.onCompleted: {
                    var idx = page.soundNames.indexOf(Settings.value("soundHold", "gong1"))
                    currentIndex = (idx >= 0) ? idx : 2
                }
            }

            Item { width: parent.width; height: Theme.paddingMedium }

            Slider {
                id: volumeSlider
                width: parent.width
                label: qsTr("Volume")
                minimumValue: 0
                maximumValue: 100
                stepSize: 5
                value: Settings.value("volume", "50")
                valueText: Math.round(value) + " %"
                onValueChanged: {
                    Settings.setValue("volume", "" + Math.round(value))
                }
            }
        }
    }
}
