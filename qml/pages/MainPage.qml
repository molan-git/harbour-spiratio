import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/patterns.js" as PatternsDB
import "../js/translations.js" as Tr

Page {
    id: page

    property var patterns: []
    property var customPatterns: []
    property string selectedId: ""
    property int durationMinutes: 10
    property var durations: [3, 5, 10, 15, 20, 30, 0]
    property var durationLabels: [qsTr("3 min"), qsTr("5 min"), qsTr("10 min"), qsTr("15 min"), qsTr("20 min"), qsTr("30 min"), qsTr("Endless")]

    onStatusChanged: {
        if (status === PageStatus.Active)
            reloadPatterns()
    }

    function reloadPatterns() {
        try {
            customPatterns = JSON.parse(Settings.value("customPatterns", "[]"))
        } catch (e) {
            customPatterns = []
        }
        patterns = PatternsDB.patterns.concat(customPatterns)
        selectedId = Settings.value("lastPattern", "")
        if (!findPattern(selectedId) && patterns.length > 0)
            selectedId = patterns[0].id
    }

    function findPattern(id) {
        for (var i = 0; i < patterns.length; i++)
            if (patterns[i].id === id)
                return patterns[i]
        return null
    }

    function selectPattern(id) {
        selectedId = id
        Settings.setValue("lastPattern", id)
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: qsTr("Add custom breathing pattern")
                onClicked: pageStack.push("PatternEditorPage.qml")
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: 0

            PageHeader { title: qsTr("Spiratio") }

            SectionHeader { text: qsTr("Duration") }

            ComboBox {
                id: durationCombo
                width: parent.width
                label: qsTr("Session length")
                currentIndex: -1
                menu: ContextMenu {
                    Repeater {
                        model: page.durationLabels.length
                        MenuItem {
                            text: page.durationLabels[index]
                            onClicked: {
                                page.durationMinutes = page.durations[index]
                                Settings.setValue("duration", "" + page.durationMinutes)
                            }
                        }
                    }
                }
                Component.onCompleted: {
                    var saved = parseInt(Settings.value("duration", "10"))
                    var idx = page.durations.indexOf(saved)
                    currentIndex = (idx >= 0) ? idx : page.durations.indexOf(10)
                    page.durationMinutes = page.durations[currentIndex]
                }
                description: page.durationMinutes > 0
                             ? qsTr("Ends automatically after %1 minutes").arg(page.durationMinutes)
                             : qsTr("Runs until you stop it")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Start")
                width: parent.width * 0.8
                enabled: page.findPattern(page.selectedId) !== null
                onClicked: if (!pageStack.busy) {
                    pageStack.push("SessionPage.qml", {
                        pattern: page.findPattern(page.selectedId),
                        durationMinutes: page.durationMinutes
                    })
                }
            }

            SectionHeader { text: qsTr("Breathing patterns") }

            Repeater {
                model: PatternsDB.patterns.length
                TextSwitch {
                    width: column.width
                    automaticCheck: false
                    checked: page.selectedId === PatternsDB.patterns[index].id
                    text: Tr.trName(PatternsDB.patterns[index].id) + " (" + PatternsDB.patterns[index].tag + ")"
                    description: Tr.trBenefit(PatternsDB.patterns[index].id)
                    onClicked: page.selectPattern(PatternsDB.patterns[index].id)
                }
            }

            SectionHeader {
                text: qsTr("Custom breathing patterns")
                visible: page.customPatterns.length > 0
            }

            Repeater {
                model: page.customPatterns.length
                visible: page.customPatterns.length > 0
                ListItem {
                    id: customItem
                    width: column.width
                    contentHeight: Theme.itemSizeMedium
                    menu: Component {
                        ContextMenu {
                            MenuItem {
                                text: qsTr("Edit")
                                onClicked: pageStack.push("PatternEditorPage.qml",
                                                          { editing: page.customPatterns[index] })
                            }
                            MenuItem {
                                text: qsTr("Delete")
                                onClicked: {
                                    var list = page.customPatterns
                                    list.splice(index, 1)
                                    Settings.setValue("customPatterns", JSON.stringify(list))
                                    page.reloadPatterns()
                                }
                            }
                        }
                    }
                    TextSwitch {
                        width: parent.width
                        automaticCheck: false
                        checked: page.selectedId === page.customPatterns[index].id
                        text: page.customPatterns[index].name + " (" + page.customPatterns[index].tag + ")"
                        description: page.customPatterns[index].benefit
                        onClicked: page.selectPattern(page.customPatterns[index].id)
                        onPressAndHold: customItem.showMenu()
                    }
                }
            }

            Item { width: parent.width; height: Theme.paddingLarge }
        }
        VerticalScrollDecorator {}
    }
}
