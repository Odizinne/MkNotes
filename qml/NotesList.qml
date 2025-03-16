import QtQuick.Controls.FluentWinUI3
import QtQuick
import QtQuick.Layouts

Pane {
    id: notesList

    property int currentIndex: -1
    property var notesModel: null

    signal addNoteRequested()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ItemDelegate {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            highlighted: true

            contentItem: RowLayout {
                spacing: 10

                Label {
                    text: "+"
                    font.pixelSize: 18
                    font.bold: true
                }

                Label {
                    text: "New Note"
                    font.pixelSize: 14
                }
            }

            onClicked: {
                notesList.addNoteRequested()
            }
        }

        ListView {
            id: notesListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: notesList.notesModel
            clip: true

            onCurrentIndexChanged: {
                notesList.currentIndex = currentIndex
            }

            delegate: ItemDelegate {
                id: del
                width: notesListView.width
                height: 60
                highlighted: ListView.isCurrentItem
                required property int index
                required property string title
                required property var created

                contentItem: ColumnLayout {
                    spacing: 2

                    Label {
                        Layout.fillWidth: true
                        text: del.title || "Untitled Note"
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        maximumLineCount: 1
                    }

                    Label {
                        Layout.fillWidth: true
                        text: {
                            const date = new Date(del.created)
                            return date.toLocaleDateString()
                        }
                        font.pixelSize: 10
                        opacity: 0.7
                    }
                }

                onClicked: {
                    notesListView.currentIndex = del.index
                }
            }
        }
    }

    onCurrentIndexChanged: {
        if (notesListView.currentIndex !== currentIndex) {
            notesListView.currentIndex = currentIndex
        }
    }
}
