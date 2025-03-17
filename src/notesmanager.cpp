#include "include/notesmanager.h"
#include <QDir>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QDateTime>
#include <QRandomGenerator>
#include <QDebug>
#include <QFile>

NotesManager::NotesManager(QObject* parent) : QObject(parent)
{
    // Create notes directory if it doesn't exist
    ensureDirectoryExists(getNotesDirectory());
}

QString NotesManager::getNotesDirectory()
{
    QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    return appDataPath + "/Notes";
}

bool NotesManager::ensureDirectoryExists(const QString& path)
{
    QDir dir(path);
    if (!dir.exists()) {
        return dir.mkpath(".");
    }
    return true;
}

QString NotesManager::saveNote(const QString& id, const QString& title, const QString& content, const QDateTime& created)
{
    // Don't save empty notes
    if (content.trimmed().isEmpty()) {
        return "Note is empty";
    }

    // Create note data
    QJsonObject noteData;
    noteData["id"] = id;
    noteData["title"] = title;
    noteData["content"] = content;
    noteData["created"] = created.toString(Qt::ISODate);

    // Convert to JSON
    QJsonDocument doc(noteData);
    QByteArray jsonData = doc.toJson(QJsonDocument::Indented);

    // Get file path
    QString filePath = getNotesDirectory() + "/" + id + ".json";

    // Write to file
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
        return "Failed to open file for writing: " + file.errorString();
    }

    file.write(jsonData);
    file.close();

    return "success";
}

QJsonArray NotesManager::loadNotes()
{
    QJsonArray notesArray;
    QString notesDir = getNotesDirectory();

    QDir dir(notesDir);
    QStringList filters;
    filters << "*.json";
    dir.setNameFilters(filters);

    QFileInfoList fileList = dir.entryInfoList(QDir::Files, QDir::Time); // Sort by time, newest first

    foreach (const QFileInfo &fileInfo, fileList) {
        QFile file(fileInfo.absoluteFilePath());

        if (file.open(QIODevice::ReadOnly)) {
            QByteArray data = file.readAll();
            QJsonDocument doc = QJsonDocument::fromJson(data);

            if (doc.isObject()) {
                notesArray.append(doc.object());
            }

            file.close();
        }
    }

    return notesArray;
}

QString NotesManager::generateNoteId()
{
    QString timestamp = QString::number(QDateTime::currentMSecsSinceEpoch());
    QString random = QString::number(QRandomGenerator::global()->bounded(1000));
    return timestamp + random;
}

bool NotesManager::deleteNote(const QString& id)
{
    QString filePath = getNotesDirectory() + "/" + id + ".json";
    QFile file(filePath);
    return file.remove();
}
