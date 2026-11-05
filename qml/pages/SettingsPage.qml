import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property bool soundEnabled: Settings.value("soundEnabled", "true") === "true"
    property real volume: Settings.value("volume", "80")
    property string soundIn: Settings.value("soundIn", "bell1")
    property string soundOut: Settings.value("soundOut", "bell2")
    property string soundHold: Settings.value("soundHold", "gong1")

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader { title: qsTr("Settings") }

            SectionHeader { text: qsTr("Sounds") }

            TextSwitch {
                width: parent.width
                text: qsTr("Sound")
                description: qsTr("Play a sound when the breathing direction changes")
                checked: page.soundEnabled
                automaticCheck: true
                onCheckedChanged: {
                    if (checked !== page.soundEnabled) {
                        page.soundEnabled = checked
                        Settings.setValue("soundEnabled", checked ? "true" : "false")
                    }
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
                }
                onCurrentIndexChanged: {
                    var names = ["bell1", "bell2", "gong1"]
                    page.soundIn = names[currentIndex]
                    Settings.setValue("soundIn", page.soundIn)
                }
                Component.onCompleted: {
                    var idx = ["bell1", "bell2", "gong1"].indexOf(page.soundIn)
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
                }
                onCurrentIndexChanged: {
                    var names = ["bell1", "bell2", "gong1"]
                    page.soundOut = names[currentIndex]
                    Settings.setValue("soundOut", page.soundOut)
                }
                Component.onCompleted: {
                    var idx = ["bell1", "bell2", "gong1"].indexOf(page.soundOut)
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
                }
                onCurrentIndexChanged: {
                    var names = ["bell1", "bell2", "gong1"]
                    page.soundHold = names[currentIndex]
                    Settings.setValue("soundHold", page.soundHold)
                }
                Component.onCompleted: {
                    var idx = ["bell1", "bell2", "gong1"].indexOf(page.soundHold)
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
                value: page.volume
                valueText: Math.round(value) + " %"
                onValueChanged: {
                    page.volume = value
                    Settings.setValue("volume", "" + Math.round(value))
                }
            }
        }
    }
}
