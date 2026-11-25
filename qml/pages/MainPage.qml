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
    property int durationMinutes: 10
    property var durations: [1, 3, 5, 10, 15, 20, 30, 0]
    property var durationLabels: [qsTr("1 min"), qsTr("3 min"), qsTr("5 min"), qsTr("10 min"), qsTr("15 min"), qsTr("20 min"), qsTr("30 min"), qsTr("Endless")]

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
        try {
            customPatterns = JSON.parse(Settings.value("customPatterns", "[]"))
        } catch (e) {
            customPatterns = []
        }
        patterns = customPatterns.concat(vis)
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

    function hidePattern(id) {
        Settings.setValue("hidden_" + id, "true")
        reloadPatterns()
    }

    function deleteCustomPattern(id) {
        for (var i = 0; i < customPatterns.length; i++) {
            if (customPatterns[i].id === id)
                customPatterns.splice(i, 1)
        }
        Settings.setValue("customPatterns", JSON.stringify(customPatterns))
        reloadPatterns()
    }

    function isCustom(p) {
        return p && typeof p.id === "string" && p.id.substring(0, 7) === "custom-"
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

            Item { width: parent.width; height: Theme.paddingSmall * 0.5 }

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
                text: qsTr("Breathing patterns")
            }

            Repeater {
                model: page.patterns

                ListItem {
                    id: patternItem
                    width: column.width
                    contentHeight: Theme.itemSizeMedium
                    menu: page.isCustom(modelData) ? customMenuC : presetMenuC

                    Component {
                        id: customMenuC
                        ContextMenu {
                            MenuItem {
                                text: qsTr("Edit")
                                onClicked: pageStack.push("PatternEditorPage.qml",
                                                          { editing: page.patterns[index] })
                            }
                            MenuItem {
                                text: qsTr("Delete")
                                onClicked: page.deleteCustomPattern(page.patterns[index].id)
                            }
                        }
                    }
                    Component {
                        id: presetMenuC
                        ContextMenu {
                            MenuItem {
                                text: qsTr("Hide")
                                onClicked: page.hidePattern(page.patterns[index].id)
                            }
                        }
                    }

                    Loader {
                        width: parent.width
                        height: Theme.itemSizeMedium
                        sourceComponent: page.isCustom(modelData) ? customSwitchC : presetSwitchC
                    }

                    Component {
                        id: customSwitchC
                        IconTextSwitch {
                            width: parent.width
                            automaticCheck: false
                            checked: page.selectedId === page.patterns[index].id
                            icon.source: "image://theme/icon-m-media-artists"
                            text: page.patterns[index].name + " (" + page.patterns[index].tag + ")"
                            description: page.patterns[index].description
                                         ? page.patterns[index].description
                                         : page.patterns[index].benefit
                            onClicked: page.selectPattern(page.patterns[index].id)
                            onPressAndHold: patternItem.openMenu()
                        }
                    }
                    Component {
                        id: presetSwitchC
                        TextSwitch {
                            width: parent.width
                            automaticCheck: false
                            checked: page.selectedId === page.patterns[index].id
                            text: Tr.trName(page.patterns[index].id) + " (" + page.patterns[index].tag + ")"
                            description: Tr.trBenefit(page.patterns[index].id)
                            onClicked: page.selectPattern(page.patterns[index].id)
                            onPressAndHold: patternItem.openMenu()
                        }
                    }
                }
            }

            Item { width: parent.width; height: Theme.paddingLarge }
        }
        VerticalScrollDecorator {}
    }
}
