#include "mainwindow.h"
#include "fullscreen3dwindow.h"
#include <QDebug>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickWindow>

#define MAINWINDOW_URL "qrc:/FullScreen3DView/qml/Mainscreen.qml"
#define WINDOW_NAME "MainWindow"
#define DEBUG_PREFIX "[" WINDOW_NAME "]:"

MainWindow::MainWindow() {
    m_secondWindow = new FullScreen3DWindow(this);
    rootContext()->setContextProperty("mainWindow", this);

    connect(m_secondWindow, &FullScreen3DWindow::closed, this, &MainWindow::onFullScreen3DWindowClosed);
}

void MainWindow::loadMainQml() {
    load(QUrl(MAINWINDOW_URL));
}

void MainWindow::openFullScreen3DWindow(const QString &message) {
    qDebug() << DEBUG_PREFIX << "Full Screen 3D View opened.";
    m_secondWindow->show(message);
}

void MainWindow::onFullScreen3DWindowClosed() {
    qDebug() << DEBUG_PREFIX << "Full Screen 3D View closed.";
}