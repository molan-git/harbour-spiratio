import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    objectName: "CreditPage"

    allowedOrientations: defaultAllowedOrientations

    readonly property var translationCredits: [
        { language: qsTr("German"), name: "molan" }
    ]

    readonly property var soundCredits: [
        { name: "Bell 1", author: "freesound_community",
          authorUrl: "https://pixabay.com/users/freesound_community-46691455/",
          sourceUrl: "https://pixabay.com/" },
        { name: "Bell 2", author: "DRAGON-STUDIO",
          authorUrl: "https://pixabay.com/users/dragon-studio-38165424/",
          sourceUrl: "https://pixabay.com/" },
        { name: "Gong 1", author: "freesound_community",
          authorUrl: "https://pixabay.com/users/freesound_community-46691455/",
          sourceUrl: "https://pixabay.com/sound-effects/" },
        { name: "Gong 2", author: "u_n1up2g5sdg",
          authorUrl: "https://pixabay.com/users/u_n1up2g5sdg-40232378/",
          sourceUrl: "https://pixabay.com/" }
    ]

    // Hidden text used to measure the widest "label:" column
    Text {
        id: labelMetrics
        visible: false
        font.pixelSize: Theme.fontSizeExtraSmall
    }

    property real creditsLabelWidth: {
        var widest = 0
        for (var i = 0; i < translationCredits.length; ++i) {
            labelMetrics.text = translationCredits[i].language + ":"
            if (labelMetrics.implicitWidth > widest)
                widest = labelMetrics.implicitWidth
        }
        for (var j = 0; j < soundCredits.length; ++j) {
            labelMetrics.text = soundCredits[j].name + ":"
            if (labelMetrics.implicitWidth > widest)
                widest = labelMetrics.implicitWidth
        }
        return widest
    }

    function openLink(link) {
        if (link.indexOf("https://") === 0 || link.indexOf("http://") === 0)
            Qt.openUrlExternally(link)
    }

    function link(url, label) {
        return "<a href=\"" + url + "\">" + label + "</a>"
    }

    SilicaListView {
        id: creditList
        anchors.fill: parent

        header: Column {
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader { title: qsTr("Credits") }

            SectionHeader { text: qsTr("Translations") }

            Column {
                id: translationContent
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingSmall

                Repeater {
                    model: page.translationCredits
                    delegate: Row {
                        width: translationContent.width
                        spacing: Theme.paddingMedium

                        Text {
                            width: page.creditsLabelWidth
                            text: modelData.language + ":"
                            color: Theme.highlightColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                            wrapMode: Text.NoWrap
                        }
                        Text {
                            width: translationContent.width - page.creditsLabelWidth - Theme.paddingMedium
                            text: modelData.name
                            color: Theme.highlightColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                            wrapMode: Text.NoWrap
                        }
                    }
                }
            }

            SectionHeader { text: qsTr("Audio files") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("Files have been manually edited for use in this app under the") +
                      " " +
                      page.link("https://pixabay.com/service/license-summary/",
                                qsTr("Pixabay Content License")) +
                      ":"
                color: Theme.highlightColor
                linkColor: Theme.primaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                textFormat: Text.StyledText

                onLinkActivated: openLink(link)
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }
        }

        model: page.soundCredits

        delegate: ListItem {
            contentHeight: creditContent.height + Theme.paddingSmall / 2

            Row {
                id: creditContent
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingMedium

                Text {
                    width: page.creditsLabelWidth
                    text: modelData.name + ":"
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.NoWrap
                }
                Text {
                    width: creditContent.width - page.creditsLabelWidth - creditContent.spacing
                    textFormat: Text.StyledText
                    wrapMode: Text.NoWrap
                    color: Theme.highlightColor
                    linkColor: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: page.link(modelData.authorUrl, modelData.author) +
                          " - " +
                          page.link(modelData.sourceUrl, "Pixabay")
                    onLinkActivated: openLink(link)
                }
            }
        }

        footer: Item {
            width: parent.width
            height: Theme.paddingMedium
        }

        VerticalScrollDecorator {}
    }
}
