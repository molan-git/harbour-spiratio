import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/patterns.js" as PatternsDB
import "../js/translations.js" as Tr

Page {
    id: page

    property var customPatterns: []
    property var patterns: []
    property string selectedId: ""
    property int revision: 0
    property bool hasVisiblePresets: false
    property int durationMinutes: 10
    property var durations: [3, 5, 10, 15, 20, 30, 0]
    property var durationLabels: [qsTr("3 min"), qsTr("5 min"), qsTr("10 min"), qsTr("15 min"), qsTr("20 min"), qsTr("30 min"), qsTr("Endless")]

    onStatusChanged: {
        if (status === PageStatus.Active)
            reloadPatterns()
    }

    function patternVisible(id) {
        return revision >= 0 && Settings.value("hidden_" + id, "false") !== "true"
    }

    function visiblePresets() {
        var vis = []
        for (var i = 0; i < PatternsDB.patterns.length; i++) {
            if (patternVisible(PatternsDB.patterns[i].id))
                vis.push(PatternsDB.patterns[i])
        }
        return vis
    }

    function reloadPatterns() {
        revision++
        var vis = visiblePresets()
        hasVisiblePresets = vis.length > 0
        try {
            customPatterns = JSON.parse(Settings.value("customPatterns", "[]"))
        } catch (e) {
            customPatterns = []
        }
        patterns = vis.concat(customPatterns)
        selectedId = Settings.value("lastPattern", "")
        if (!findPattern(selectedId) && patterns.length > 0)
            selectedId = patterns[0].id
    }

    function hidePattern(id) {
        Settings.setValue("hidden_" + id, "true")
        reloadPatterns()
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
                text: qsTr("Add breathing pattern")
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
            }

            Item { width: parent.width; height: Theme.paddingSmall }

            IconButton {
                anchors.horizontalCenter: parent.horizontalCenter
                icon.source: "image://theme/icon-l-play"
                enabled: page.findPattern(page.selectedId) !== null
                onClicked: if (!pageStack.busy) {
                    pageStack.push("SessionPage.qml", {
                        pattern: page.findPattern(page.selectedId),
                        durationMinutes: page.durationMinutes
                    })
                }
            }

            Item { width: parent.width; height: Theme.paddingSmall }

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
                                    var idx = index
                                    var p = page
                                    var s = Settings
                                    customItem.remorseDelete(function() {
                                        var list = p.customPatterns
                                        list.splice(idx, 1)
                                        s.setValue("customPatterns", JSON.stringify(list))
                                        p.reloadPatterns()
                                    })
                                }
                            }
                        }
                    }
                    TextSwitch {
                        width: parent.width
                        automaticCheck: false
                        checked: page.selectedId === page.customPatterns[index].id
                        text: page.customPatterns[index].name + " (" + page.customPatterns[index].tag + ")"
                        description: page.customPatterns[index].description
                                     ? page.customPatterns[index].description
                                     : page.customPatterns[index].benefit
                        onClicked: page.selectPattern(page.customPatterns[index].id)
                        onPressAndHold: customItem.showMenu()
                    }
                }
            }

            SectionHeader {
                text: qsTr("Breathing patterns")
                visible: page.hasVisiblePresets
            }

            Repeater {
                model: PatternsDB.patterns

                ListItem {
                    id: presetItem
                    width: column.width
                    visible: page.patternVisible(modelData.id)
                    contentHeight: Theme.itemSizeMedium
                    menu: Component {
                        ContextMenu {
                            MenuItem {
                                text: qsTr("Hide")
                                onClicked: page.hidePattern(modelData.id)
                            }
                        }
                    }
                    TextSwitch {
                        width: parent.width
                        automaticCheck: false
                        checked: page.selectedId === modelData.id
                        text: Tr.trName(modelData.id) + " (" + modelData.tag + ")"
                        description: Tr.trBenefit(modelData.id)
                        onClicked: page.selectPattern(modelData.id)
                        onPressAndHold: presetItem.showMenu()
                    }
                }
            }

            Item { width: parent.width; height: Theme.paddingLarge }
        }
        VerticalScrollDecorator {}
    }
}
