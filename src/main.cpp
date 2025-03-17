#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QTranslator>
#include <QLocale>

const QMap<QString, QString>& getSystemLanguageMap() {
    static const QMap<QString, QString> map {
        {"en", "en"},
        {"fr", "fr"}
    };
    return map;
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("Odizinne");
    app.setApplicationName("Retr0Mine");
    QGuiApplication::setWindowIcon(QIcon(":/icons/icon.png"));

    QLocale locale;
    QString languageCode = getSystemLanguageMap().value(locale.name(), "en");
    QTranslator translator;

    QString filePath = ":/i18n/MkNotes_" + languageCode + ".qm";
    if (translator.load(filePath)) {
        app.installTranslator(&translator);
    }

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("net.odizinne.mknotes", "Main");

    return app.exec();
}
