import QtQuick.Controls.FluentWinUI3
import QtQuick
import net.odizinne.mknotes

ApplicationWindow {
    id: root
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600
    visible: true
    title: qsTr("Markdown Notes")

    property bool isClosing: false
    property NotesManager notesManager: NotesManager

    NotesModel {
        id: notesModel
        Component.onCompleted: {
            loadNotes()

            if (count > 0) {
                notesList.currentIndex = 0
            }
        }
    }

    onClosing: function(close) {
        isClosing = true
        noteEditor.checkForEmptyNote()
    }

    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal
        handle: ToolSeparator {
            MouseArea {
                anchors.fill: parent
                onPressed: function(mouse) { mouse.accepted = true }
                onReleased: function(mouse) { mouse.accepted = true }
                onClicked: function(mouse) { mouse.accepted = true }
                onPositionChanged: function(mouse) { mouse.accepted = true }
            }
        }

        NotesList {
            id: notesList
            SplitView.preferredWidth: 200
            SplitView.minimumWidth: 200
            SplitView.maximumWidth: 200

            notesModel: notesModel

            onAddNoteRequested: {
                notesModel.addNewNote()
                currentIndex = 0
            }
        }

        NoteEditor {
            id: noteEditor
            SplitView.fillWidth: true

            notesModel: notesModel
            currentIndex: notesList.currentIndex

            onEmptyNoteDetected: function(index) {
                if (index >= 0 && index < notesModel.count) {
                    var noteId = notesModel.get(index).id

                    root.notesManager.deleteNote(noteId)

                    if (!root.isClosing) {
                        notesModel.remove(index)

                        if (notesModel.count === 0) {
                            notesModel.addNewNote()
                            notesList.currentIndex = 0
                        } else if (notesList.currentIndex >= notesModel.count) {
                            notesList.currentIndex = notesModel.count - 1
                        }
                    } else {
                        console.log("Deleted empty note at index: " + index)
                    }
                }
            }

            onDeleteRequested: function(index) {
                if (index >= 0) {
                    var noteId = notesModel.get(index).id

                    notesManager.deleteNote(noteId)

                    notesModel.remove(index)

                    if (notesModel.count === 0) {
                        notesModel.addNewNote()
                        notesList.currentIndex = 0
                        noteEditor.clearText()
                    } else if (notesList.currentIndex >= notesModel.count) {
                        notesList.currentIndex = notesModel.count - 1
                    }
                }
            }
        }
    }
}
