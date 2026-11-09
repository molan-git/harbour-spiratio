import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/patterns.js" as PatternsDB

Page {
    id: page

    property var editing: null
    property string attentionText: ""

    onStatusChanged: {
        if (status === PageStatus.Active && editing) {
            nameField.text = editing.name
            var p = editing.phases
            inField.text = phaseLen(p, "in", 0)
            holdInField.text = phaseLen(p, "hold", 0)
            outField.text = phaseLen(p, "out", 0)
            holdOutField.text = phaseLen(p, "hold", 1)
        }
    }

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
        attentionText = ""

        var inS = parseInt(inField.text) || 0
        var hInS = parseInt(holdInField.text) || 0
        var outS = parseInt(outField.text) || 0
        var hOutS = parseInt(holdOutField.text) || 0
        var nm = nameField.text.trim()

        if (nm.length === 0) { attentionText = qsTr("Please give the pattern a name"); return }
        if (inS <= 0 || outS <= 0) { attentionText = qsTr("Inhale and exhale must be at least 1 second"); return }

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
        pageStack.pop()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: editing ? qsTr("Edit pattern") : qsTr("New pattern")
            }

            TextField {
                id: nameField
                width: parent.width
                label: qsTr("Name")
                placeholderText: qsTr("e.g. Evening calm")
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                onTextChanged: page.attentionText = ""
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
                    onTextChanged: page.attentionText = ""
                }
                TextField {
                    id: holdInField
                    width: (parent.width - parent.spacing) / 2
                    label: qsTr("Hold after in (s)")
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: "0"
                    onTextChanged: page.attentionText = ""
                }
                TextField {
                    id: outField
                    width: (parent.width - parent.spacing) / 2
                    label: qsTr("Breath out (s)")
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: "4"
                    onTextChanged: page.attentionText = ""
                }
                TextField {
                    id: holdOutField
                    width: (parent.width - parent.spacing) / 2
                    label: qsTr("Hold after out (s)")
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: "0"
                    onTextChanged: page.attentionText = ""
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("Set a hold to 0 to skip it. Example: in 4, hold 3, out 5, hold 3.")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: editing ? qsTr("Save changes") : qsTr("Save pattern")
                preferredWidth: Theme.buttonWidthLarge
                onClicked: page.save()
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                visible: page.attentionText.length > 0
                text: page.attentionText
                color: Theme.errorColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
            }
        }
    }
}
