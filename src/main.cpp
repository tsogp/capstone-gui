#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDirIterator>
#include <QDebug>

void printResources() {
    qDebug() << "Available resources under :/FullScreen3DView:";
    QDirIterator it(":/FullScreen3DView", QDirIterator::Subdirectories);
    while (it.hasNext()) {
        qDebug() << it.next();
    }
}


int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    printResources();

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("FullScreen3DView", "Main");

    return app.exec();
}
