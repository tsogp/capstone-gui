#include "mainwindow.h"

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

#include <QGuiApplication>

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    printResources();

    MainWindow mainWindow;
    mainWindow.loadMainQml();

    return app.exec();
}
