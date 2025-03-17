import QtQuick.Controls.FluentWinUI3
import QtQuick
import QtQuick.Layouts
import net.odizinne.mknotes

Pane {
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

            notesModel.setProperty(currentIndex, "content", textArea.plainContent)

            const firstLine = textArea.plainContent.split('\n')[0] || ""
            const cleanTitle = firstLine.replace(/^#+\s*|[*_~`]/g, "")
            notesModel.setProperty(currentIndex, "title", cleanTitle || qsTr("Untitled"))

            NotesManager.saveNote(note.id, cleanTitle || qsTr("Untitled"), textArea.plainContent, note.created)
        }
    }

    function checkForEmptyNote() {
        if (currentIndex >= 0 && notesModel && textArea.plainContent.trim() === "") {
            emptyNoteDetected(currentIndex)
        }
    }

    // Function to prepare text for markdown viewing with proper paragraph spacing
    function formatMarkdownText(text) {
        // Use non-breaking spaces to ensure empty lines create proper spacing
        // Replace double newlines with a special marker to preserve them
        return text.replace(/\n\n/g, "\n\n&nbsp;\n\n");
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            TempScrollBar {
                id: fluentVerticalScrollBar
                enabled: scrollView.enabled
                opacity: scrollView.opacity
                orientation: Qt.Vertical
                anchors.right: scrollView.right
                anchors.top: scrollView.top
                anchors.bottom: scrollView.bottom
                visible: policy === ScrollBar.AlwaysOn
                active: true
                policy: (scrollView.contentHeight > scrollView.height) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            }

            ScrollView {
                id: scrollView
                anchors.fill: parent
                visible: editorPane.currentIndex >= 0
                ScrollBar.vertical: fluentVerticalScrollBar
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                TextArea {
                    id: textArea
                    wrapMode: TextEdit.Wrap
                    width: parent.width
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignTop

                    // Original content
                    property string plainContent: ""

                    textFormat: editorPane.editEnabled ? TextEdit.PlainText : TextEdit.MarkdownText
                    readOnly: !editorPane.editEnabled

                    // Add some padding for better readability in markdown view
                    leftPadding: editorPane.editEnabled ? 6 : 10
                    rightPadding: editorPane.editEnabled ? 6 : 10
                    topPadding: editorPane.editEnabled ? 6 : 10
                    bottomPadding: editorPane.editEnabled ? 6 : 10

                    onTextChanged: {
                        if (editorPane.editEnabled && editorPane.currentIndex >= 0 && editorPane.notesModel) {
                            // Store the plain content when in edit mode
                            plainContent = text

                            const firstLine = text.split('\n')[0] || ""
                            const cleanTitle = firstLine.replace(/^#+\s*|[*_~`]/g, "")
                            notesModel.setProperty(currentIndex, "title", cleanTitle || qsTr("Untitled"))

                            saveCurrentNote()
                        }
                    }

                    // Handle switching between modes
                    Connections {
                        target: editorPane
                        function onEditEnabledChanged() {
                            if (editorPane.editEnabled) {
                                // Switch to edit mode - use the stored plain content
                                if (textArea.plainContent) {
                                    textArea.text = textArea.plainContent
                                }
                            } else {
                                // Switch to formatted mode - store current text before formatting
                                textArea.plainContent = textArea.text

                                // Format the text for markdown viewing with proper paragraph spacing
                                textArea.text = formatMarkdownText(textArea.plainContent)
                            }
                        }
                    }
                }
            }
        }
        Label {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: editorPane.currentIndex < 0
            text: qsTr("Create a note to get started")
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    onCurrentIndexChanged: {
        if (currentIndex >= 0 && notesModel && notesModel.count > 0) {
            var content = notesModel.get(currentIndex).content
            textArea.plainContent = content

            if (editorPane.editEnabled) {
                textArea.text = content
            } else {
                textArea.text = formatMarkdownText(content)
            }
        } else {
            textArea.text = ""
            textArea.plainContent = ""
        }
    }

    Component.onDestruction: {
        checkForEmptyNote()
    }
}
