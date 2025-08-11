#include "boxdata.h"
#include "mainwindow.h"

#include <QDebug>
#include <QDirIterator>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    app.setOrganizationName(APP_ORGANIZATION_NAME);
    app.setApplicationName(APP_NAME);

    QQuickStyle::setStyle("Material");
    qputenv("QT_QUICK_CONTROLS_MATERIAL_THEME", QByteArray("Light"));

    qRegisterMetaType<BoxData>("BoxData");

    MainWindow mainWindow;
    mainWindow.loadMainQml();

    return app.exec();
}