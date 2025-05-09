import QtQuick.Controls.Material
import QtQuick.Layouts
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
    Material.theme: AppSettings.darkMode ? Material.Dark : Material.Light
    Material.accent: Material.Pink
    Material.primary: Material.Indigo
    color: Material.theme === Material.Dark ? "#1C1C1C" : "#E3E3E3"

    header: ToolBar {
        height: 40

        Item {
            anchors.right: themeSwitch.left
            height: 24
            width: 24
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: sunImage
                anchors.fill: parent
                source: "qrc:/icons/sun.png"
                opacity: !themeSwitch.checked ? 1 : 0
                rotation: themeSwitch.checked ? 360 : 0
                mipmap: true

                Behavior on rotation {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutQuad
                    }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 500 }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: themeSwitch.checked = !themeSwitch.checked
                }
            }

            Image {
                anchors.fill: parent
                id: moonImage
                source: "qrc:/icons/moon.png"
                opacity: themeSwitch.checked ? 1 : 0
                rotation: themeSwitch.checked ? 360 : 0
                mipmap: true

                Behavior on rotation {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutQuad
                    }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 100 }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: themeSwitch.checked = !themeSwitch.checked
                }
            }
        }

        Switch {
            anchors.right: parent.right
            height: 40
            id: themeSwitch
            checked: AppSettings.darkMode
            onClicked: AppSettings.darkMode = checked
        }
    }

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

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15
        NotesList {
            Layout.fillHeight: true
            Layout.preferredWidth: 250
            id: notesList
            notesModel: notesModel
            onAddNoteRequested: {
                notesModel.addNewNote()
                currentIndex = 0

                // If this is the only note, enable edit mode automatically
                if (notesModel.count === 1) {
                    Context.editMode = true
                }
            }

            onDeleteNoteRequested: function(index) {
                if (index >= 0) {
                    var noteId = notesModel.get(index).id

                    root.notesManager.deleteNote(noteId)

                    notesModel.remove(index)

                    if (notesList.currentIndex >= notesModel.count && notesModel.count > 0) {
                        notesList.currentIndex = notesModel.count - 1
                    } else if (notesModel.count === 0) {
                        notesList.currentIndex = -1
                        noteEditor.clearText()
                    }
                }
            }
        }

        NoteEditor {
            id: noteEditor
            notesModel: notesModel
            currentIndex: notesList.currentIndex
            Layout.fillHeight: true
            Layout.fillWidth: true
            onEmptyNoteDetected: function(index) {
                if (index >= 0 && index < notesModel.count) {
                    var noteId = notesModel.get(index).id

                    root.notesManager.deleteNote(noteId)

                    if (!root.isClosing) {
                        notesModel.remove(index)

                        if (notesList.currentIndex >= notesModel.count && notesModel.count > 0) {
                            notesList.currentIndex = notesModel.count - 1
                        } else if (notesModel.count === 0) {
                            notesList.currentIndex = -1
                        }
                    } else {
                        console.log("Deleted empty note at index: " + index)
                    }
                }
            }

            onDeleteRequested: function(index) {
                if (index >= 0) {
                    var noteId = notesModel.get(index).id

                    root.notesManager.deleteNote(noteId)

                    notesModel.remove(index)

                    if (notesList.currentIndex >= notesModel.count && notesModel.count > 0) {
                        notesList.currentIndex = notesModel.count - 1
                    } else if (notesModel.count === 0) {
                        notesList.currentIndex = -1
                        noteEditor.clearText()
                    }
                }
            }
        }
    }
}
