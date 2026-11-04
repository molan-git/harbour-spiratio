import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/patterns.js" as PatternsDB

Page {
    id: page

    property var editing: null   // custom pattern object when editing, null when creating

    property string nameText: ""
    property string inText: "4"
    property string holdInText: "0"
    property string outText: "4"
    property string holdOutText: "0"
    property string attentionText: ""

    onStatusChanged: {
        if (status === PageStatus.Active && editing) {
            nameText = editing.name
            var p = editing.phases
            inText = phaseLen(p, "in", 0)
            outText = phaseLen(p, "out", 0)
            holdInText = phaseLen(p, "hold", 0)
            holdOutText = phaseLen(p, "hold", 1)
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
        if (hInS > 0)  phases.push({ t: "hold",  s: hInS })
        if (outS > 0)  phases.push({ t: "out",   s: outS })
        if (hOutS > 0) phases.push({ t: "hold",  s: hOutS })
        return phases
    }

    function save() {
        var inS = parseInt(inText) || 0
        var hInS = parseInt(holdInText) || 0
        var outS = parseInt(outText) || 0
        var hOutS = parseInt(holdOutText) || 0
        var nm = nameText.trim()

        if (nm.length === 0) { attentionText = "Please give the pattern a name"; return }
        if (inS <= 0 || outS <= 0) { attentionText = "Inhale and exhale must be at least 1 second"; return }

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
            benefit: "Custom",
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
                title: editing ? "Edit pattern" : "New pattern"
                description: "Breath in, hold, breath out, hold — in seconds"
            }

            TextField {
                id: nameField
                width: parent.width
                label: "Name"
                placeholderText: "e.g. Evening calm"
                text: page.nameText
                onTextChanged: page.nameText = text
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
            }

            Grid {
                width: parent.width
                columns: 2
                spacing: Theme.paddingMedium

                TextField {
                    width: (parent.width - parent.spacing) / 2
                    label: "Breath in (s)"
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: page.inText
                    onTextChanged: page.inText = text
                }
                TextField {
                    width: (parent.width - parent.spacing) / 2
                    label: "Hold (s)"
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: page.holdInText
                    onTextChanged: page.holdInText = text
                }
                TextField {
                    width: (parent.width - parent.spacing) / 2
                    label: "Breath out (s)"
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: page.outText
                    onTextChanged: page.outText = text
                }
                TextField {
                    width: (parent.width - parent.spacing) / 2
                    label: "Hold (s)"
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: page.holdOutText
                    onTextChanged: page.holdOutText = text
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: "Set a hold to 0 to skip it. Example: in 4, hold 3, out 5, hold 3."
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: editing ? "Save changes" : "Save pattern"
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
