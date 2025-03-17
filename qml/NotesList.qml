pragma ComponentBehavior: Bound

import QtQuick.Controls.FluentWinUI3
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl

Pane {
    id: notesList

    property int currentIndex: -1
    property var notesModel: null

    signal addNoteRequested()
    signal deleteNoteRequested(int index)

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Add search field at the top
        TextField {
            id: searchField
            Layout.fillWidth: true
            Layout.margins: 5
            placeholderText: qsTr("Filter notes...")
            selectByMouse: true
            font.pixelSize: 14
            onTextChanged: {
                notesList.filterNotesList(text)
            }

            // Clear button for the search field
            IconImage {
                visible: searchField.text.length > 0
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/icons/delete.png"
                sourceSize: Qt.size(16, 16)
                color: Constants.foregroundColor

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -5
                    onClicked: searchField.text = ""
                }
            }
        }

        ItemDelegate {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            highlighted: false

            contentItem: RowLayout {
                spacing: 10

                IconImage {
                    Layout.rightMargin: 0
                    source: "qrc:/icons/plus.png"
                    sourceSize: Qt.size(14, 14)
                    color: Constants.foregroundColor
                }

                Label {
                    text: qsTr("New Note")
                    Layout.fillWidth: true
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
                height: visible ? 60 : 0
                highlighted: ListView.isCurrentItem
                required property int index
                required property string title
                required property var created
                focusPolicy: Qt.NoFocus
                visible: true // Will be controlled by the filter function

                contentItem: GridLayout {
                    columns: 2
                    rowSpacing: 2
                    columnSpacing: 5
                    focusPolicy: Qt.NoFocus

                    // Title (top-left)
                    Label {
                        Layout.fillWidth: true
                        Layout.column: 0
                        Layout.row: 0
                        text: del.title || qsTr("Untitled")
                        font.pixelSize: 16
                        font.bold: true
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        maximumLineCount: 1
                        focusPolicy: Qt.NoFocus
                    }

                    // Date (bottom-left)
                    Label {
                        Layout.fillWidth: true
                        Layout.column: 0
                        Layout.row: 1
                        text: {
                            const date = new Date(del.created)
                            return date.toLocaleDateString()
                        }
                        font.pixelSize: 11
                        opacity: 0.7
                        focusPolicy: Qt.NoFocus
                    }

                    // Delete button (spanning both rows on the right)
                    Button {
                        id: deleteButton
                        Layout.preferredWidth: height
                        Layout.column: 1
                        Layout.row: 0
                        Layout.rowSpan: 2
                        Layout.alignment: Qt.AlignCenter
                        visible: del.highlighted
                        flat: true
                        onClicked: {
                            if (del.index >= 0) {
                                notesList.deleteNoteRequested(del.index)
                            }
                        }

                        focusPolicy: Qt.NoFocus

                        IconImage {
                            anchors.fill: parent
                            source: "qrc:/icons/delete.png"
                            color: Constants.foregroundColor
                            sourceSize.width: parent.width / 2
                            sourceSize.height: parent.height / 2
                        }
                    }
                }

                onClicked: {
                    notesListView.currentIndex = del.index
                }
            }
        }

        Button {
            id: editButton
            text: qsTr("Edit mode")
            icon.source: "qrc:/icons/edit.png"
            icon.color: Constants.foregroundColor
            checkable: true
            checked: Context.editMode
            Layout.fillWidth: true
            enabled: notesList.notesModel && notesList.notesModel.count > 0
            onCheckedChanged: {
                Context.editMode = checked
            }
            focusPolicy: Qt.NoFocus
        }
    }

    // Filter function to show/hide notes based on search text
    function filterNotesList(query) {
        for (var i = 0; i < notesListView.count; i++) {
            var item = notesListView.itemAtIndex(i)
            if (item) {
                var noteTitle = notesList.notesModel.get(i).title || qsTr("Untitled")
                var visible = noteTitle.toLowerCase().includes(query.toLowerCase())
                item.height = visible ? 60 : 0
                item.visible = visible
            }
        }
    }

    onCurrentIndexChanged: {
        if (notesListView.currentIndex !== currentIndex) {
            notesListView.currentIndex = currentIndex
        }
    }

    // Update edit button state when the model changes
    Connections {
        target: notesList.notesModel
        function onCountChanged() {
            editButton.enabled = notesList.notesModel && notesList.notesModel.count > 0
        }
    }
}
