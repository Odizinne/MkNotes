import QtQuick
import net.odizinne.mknotes

ListModel {
    id: notesModelRoot

    signal loadCompleted()

    function addNewNote() {
        var noteId = NotesManager.generateNoteId()
        insert(0, {
            id: noteId,
            title: "Untitled Note",
            content: "",
            created: new Date()
        })
        return 0
    }

    function loadNotes() {
        clear()

        var notesArray = NotesManager.loadNotes()

        for (var i = 0; i < notesArray.length; i++) {
            var note = notesArray[i]
            append({
                id: note.id,
                title: note.title,
                content: note.content,
                created: new Date(note.created)
            })
        }

        if (count === 0) {
            addNewNote()
        }

        loadCompleted()
    }
}
