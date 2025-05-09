import QtQuick.Controls.Material
import QtQuick
import QtQuick.Layouts
import net.odizinne.mknotes

Item {
    id: editorPane

    property int currentIndex: -1
    property bool editEnabled: Context.editMode
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
            notesModel.setProperty(currentIndex, "title", cleanTitle || qsTr("Untitled"))

            NotesManager.saveNote(note.id, cleanTitle || qsTr("Untitled"), textArea.text, note.created)
        }
    }

    function checkForEmptyNote() {
        if (currentIndex >= 0 && notesModel && textArea.text.trim() === "") {
            emptyNoteDetected(currentIndex)
        }
    }

    ScrollView {
        id: scrollView
        visible: editorPane.currentIndex >= 0
        clip: true
        anchors.fill: parent

        // Define the policies directly
        ScrollBar.vertical.policy: textArea.contentHeight > scrollView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        property bool scrollBarVisible: ScrollBar.vertical.visible

        TextArea {
            topInset: 0
            Material.containerStyle: Material.Outlined
            id: textArea
            width: scrollView.width - (scrollView.scrollBarVisible ? 25 : 0)
            //height: contentHeight
            wrapMode: TextEdit.Wrap
            textFormat: TextEdit.PlainText
            font.pixelSize: 16

            onTextChanged: {
                const firstLine = text.split('\n')[0] || ""
                const cleanTitle = firstLine.replace(/^#+\s|[_~`]/g, "")
                editorPane.notesModel.setProperty(editorPane.currentIndex, "title", cleanTitle || qsTr("Untitled"))
                editorPane.saveCurrentNote()
            }
        }
    }


    Label {
        anchors.centerIn: parent
        visible: editorPane.currentIndex < 0
        text: qsTr("Create a note to get started")
        font.pixelSize: 16
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
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
