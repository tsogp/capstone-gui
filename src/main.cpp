#include "mainwindow.h"

#include <QDebug>
#include <QDirIterator>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    MainWindow mainWindow;
    mainWindow.loadMainQml();

    return app.exec();
}