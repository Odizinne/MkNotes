import QtQuick.Controls.FluentWinUI3
import QtQuick
import QtQuick.Layouts
import net.odizinne.mknotes

Pane {
    id: editorPane

    property int currentIndex: -1
    property bool editMode: editButton.checked
    property var notesModel: null

    signal deleteRequested(int index)
    signal emptyNoteDetected(int index)

    function clearText() {
        textArea.text = ""
    }

    function saveCurrentNote() {
        if (currentIndex >= 0 && notesModel) {
            var note = notesModel.get(currentIndex)

            notesModel.setProperty(currentIndex, "content", textArea.text)

            const firstLine = textArea.text.split('\n')[0] || ""
            const cleanTitle = firstLine.replace(/^#+\s*|[*_~`]/g, "")
            notesModel.setProperty(currentIndex, "title", cleanTitle || "Untitled Note")

            NotesManager.saveNote(note.id, cleanTitle || "Untitled Note", textArea.text, note.created)
            console.log("Note saved: " + cleanTitle)
        }
    }

    function checkForEmptyNote() {
        if (currentIndex >= 0 && notesModel && textArea.text.trim() === "") {
            emptyNoteDetected(currentIndex)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        ToolBar {
            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent

                Button {
                    id: editButton
                    text: checked ? "View Mode" : "Edit Mode"
                    checkable: true
                    checked: true
                }

                Button {
                    text: "Delete"
                    visible: currentIndex >= 0

                    onClicked: function() {
                        if (currentIndex >= 0) {
                            deleteRequested(currentIndex)
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }

        // Main text area
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: currentIndex >= 0

            TextArea {
                id: textArea
                wrapMode: TextEdit.Wrap
                width: parent.width
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop

                textFormat: editMode ? TextEdit.PlainText : TextEdit.MarkdownText
                readOnly: !editMode

                onTextChanged: {
                    if (editMode && currentIndex >= 0 && notesModel) {
                        const firstLine = text.split('\n')[0] || ""
                        const cleanTitle = firstLine.replace(/^#+\s*|[*_~`]/g, "")
                        notesModel.setProperty(currentIndex, "title", cleanTitle || "Untitled Note")

                        saveCurrentNote()
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: currentIndex < 0
            text: "Select a note or create a new one"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    onCurrentIndexChanged: {
        if (currentIndex >= 0 && notesModel && notesModel.count > 0) {
            textArea.text = notesModel.get(currentIndex).content
        } else {
            textArea.text = ""
        }
    }

    Component.onDestruction: {
        checkForEmptyNote()
    }
}
