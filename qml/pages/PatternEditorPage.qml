import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/patterns.js" as PatternsDB

Dialog {
    id: page

    property var editing: null

    onStatusChanged: {
        if (status === PageStatus.Active && editing) {
            nameField.text = editing.name
            descriptionField.text = editing.description ? editing.description : ""
            var p = editing.phases
            inField.text = phaseLen(p, "in", 0)
            holdInField.text = phaseLen(p, "hold", 0)
            outField.text = phaseLen(p, "out", 0)
            holdOutField.text = phaseLen(p, "hold", 1)
        }
    }
    // Accept is only possible with a name and valid in/out durations
    canAccept: nameField.text.trim().length > 0
               && (parseInt(inField.text) || 0) > 0
               && (parseInt(outField.text) || 0) > 0

    function phaseLen(phases, type, occurrence) {
        var seen = -1
        for (var i = 0; i < phases.length; i++) {
            if (phases[i].t === type) {
                seen++
                if (seen === occurrence) return "" + phases[i].s
            }
        }
        return "0"
    }

    function buildPhases(inS, hInS, outS, hOutS) {
        var phases = []
        if (inS > 0)   phases.push({ t: "in",   s: inS })
        if (hInS > 0)  phases.push({ t: "hold", s: hInS })
        if (outS > 0)  phases.push({ t: "out",  s: outS })
        if (hOutS > 0) phases.push({ t: "hold", s: hOutS })
        return phases
    }

    function save() {
        var inS = parseInt(inField.text) || 0
        var hInS = parseInt(holdInField.text) || 0
        var outS = parseInt(outField.text) || 0
        var hOutS = parseInt(holdOutField.text) || 0
        var nm = nameField.text.trim()
        var desc = descriptionField.text.trim()

        var phases = buildPhases(inS, hInS, outS, hOutS)

        var list
        try {
            list = JSON.parse(Settings.value("customPatterns", "[]"))
        } catch (e) {
            list = []
        }

        var pattern = {
            id: editing ? editing.id : ("custom-" + Date.now()),

            name: nm,
            // optional description
            description: desc,
            tag: PatternsDB.tagFromPhases(phases),
            benefit: qsTr("Custom"),
            phases: phases
        }

        if (editing) {
            for (var i = 0; i < list.length; i++) {
                if (list[i].id === editing.id) list[i] = pattern
            }
        } else {
            list.push(pattern)
        }

        Settings.setValue("customPatterns", JSON.stringify(list))
        Settings.setValue("lastPattern", pattern.id)
    }

    onDone: {
        if (result == DialogResult.Accepted)
            page.save()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            DialogHeader {
                acceptText: qsTr("Save")
            }

            TextField {
                id: nameField
                width: parent.width
                label: qsTr("Name")
                placeholderText: qsTr("e.g. Evening calm")
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
            }

            TextField {
                id: descriptionField
                width: parent.width
                label: qsTr("Description (optional)")
                placeholderText: qsTr("e.g. Slow breathing to fall asleep")
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
            }

            Grid {
                width: parent.width
                columns: 2
                spacing: Theme.paddingMedium

                TextField {
                    id: inField
                    width: (parent.width - parent.spacing) / 2
                    label: qsTr("Breath in (s)")
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: "4"
                }
                TextField {
                    id: holdInField
                    width: (parent.width - parent.spacing) / 2
                    label: qsTr("Hold after in (s)")
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: "0"
                }
                TextField {
                    id: outField
                    width: (parent.width - parent.spacing) / 2
                    label: qsTr("Breath out (s)")
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: "4"
                }
                TextField {
                    id: holdOutField
                    width: (parent.width - parent.spacing) / 2
                    label: qsTr("Hold after out (s)")
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: "0"
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("Set a hold to 0 to skip it.")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
            }
        }
    }
}
