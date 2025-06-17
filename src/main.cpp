#include "mainwindow.h"

#include <QDebug>
#include <QDirIterator>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    app.setOrganizationName(APP_ORGANIZATION_NAME);
    app.setApplicationName(APP_NAME);

    MainWindow mainWindow;
    mainWindow.loadMainQml();

    return app.exec();
}