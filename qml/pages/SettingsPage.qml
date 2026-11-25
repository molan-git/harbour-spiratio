import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import "../js/patterns.js" as PatternsDB

Page {
    id: page

    // sound file names shown in the combos, index matches the menu items
    property var soundNames: ["gong1", "gong2", "gong3", "voiceIn", "voiceOut", "voiceHold"]
    property int hiddenCount: 0

    onStatusChanged: {
        if (status === PageStatus.Active)
            updateHiddenCount()
    }

    function updateHiddenCount() {
        var n = 0
        for (var i = 0; i < PatternsDB.patterns.length; i++) {
            if (Settings.value("hidden_" + PatternsDB.patterns[i].id, "false") === "true")
                n++
        }
        hiddenCount = n
    }

    // In-app notification for restored breathing patterns
    Notification {
        id: restoredNotification
        previewSummary: qsTr("Breathing patterns restored")
        isTransient: true
        onClicked: close()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader { title: qsTr("Settings") }

            SectionHeader { text: "Sounds" }

            TextSwitch {
                width: parent.width
                text: qsTr("Play sounds")
                onCheckedChanged: Settings.setValue("soundEnabled", checked ? "true" : "false")
                Component.onCompleted: checked = Settings.value("soundEnabled", "true") === "true"
            }

            ComboBox {
                id: inCombo
                width: parent.width
                label: qsTr("Breath in")
                currentIndex: -1
                menu: ContextMenu {
                    MenuItem { text: "Gong 1" }
                    MenuItem { text: "Gong 2" }
                    MenuItem { text: "Gong 3" }
                    MenuItem { text: "Breath in - Voice" }
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
                    MenuItem { text: "Gong 1" }
                    MenuItem { text: "Gong 2" }
                    MenuItem { text: "Gong 3" }
                    MenuItem { text: "Breath out - Voice" }
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
                    MenuItem { text: "Gong 1" }
                    MenuItem { text: "Gong 2" }
                    MenuItem { text: "Gong 3" }
                    MenuItem { text: "Hold - Voice" }
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

            Item { width: parent.width; height: Theme.paddingMedium }

            SectionHeader { text: qsTr("Display") }

            TextSwitch {
                width: parent.width
                text: qsTr("Keep display on during session")
                onCheckedChanged: Settings.setValue("keepDisplayOn", checked ? "true" : "false")
                Component.onCompleted: checked = Settings.value("keepDisplayOn", "false") === "true"
            }

            SectionHeader { text: qsTr("Other") }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                preferredWidth: Theme.buttonWidthLarge
                text: qsTr("Restore hidden breathing patterns")
                enabled: page.hiddenCount > 0
                onClicked: {
                    for (var i = 0; i < PatternsDB.patterns.length; i++)
                        Settings.setValue("hidden_" + PatternsDB.patterns[i].id, "false")
                    page.updateHiddenCount()
                    restoredNotification.close()
                    restoredNotification.publish()
                }
            }
        }
    }
}
