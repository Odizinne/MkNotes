#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QJsonObject>
#include <QJsonArray>
#include <QDateTime>

class NotesManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit NotesManager(QObject *parent = nullptr);

    Q_INVOKABLE QString saveNote(const QString& id, const QString& title, const QString& content, const QDateTime& created);
    Q_INVOKABLE QJsonArray loadNotes();
    Q_INVOKABLE QString generateNoteId();
    Q_INVOKABLE bool deleteNote(const QString& id);

private:
    QString getNotesDirectory();
    bool ensureDirectoryExists(const QString& path);
};
