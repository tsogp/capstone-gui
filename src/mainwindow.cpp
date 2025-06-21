#include "mainwindow.h"
#include "fullscreen3dwindow.h"
#include <QDebug>
#include <QFile>
#include <QJsonObject>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickWindow>

#define MAINWINDOW_URL "qrc:/FullScreen3DView/qml/Mainscreen.qml"
#define WINDOW_NAME "MainWindow"
#define DEBUG_PREFIX "[" WINDOW_NAME "]:"

MainWindow::MainWindow() {
    loadPalletsJson();
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

void MainWindow::loadPalletsJson() {
    QFile file(":/FullScreen3DView/data/pallet.json"); // Adjust the path as necessary
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning("Could not open JSON file.");
        return;
    }

    QByteArray data = file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);

    if (doc.isObject() && doc.object().contains("pallets")) {
        palletArray = doc.object().value("pallets").toArray();
        qDebug() << DEBUG_PREFIX << "Pallets loaded successfully. Count:" << palletArray.size();

        for (const QJsonValue &value : palletArray) {
            QJsonObject obj = value.toObject();
            QString type = obj["type"].toString();
            QString dimension = obj["dimension"].toString();
            QString load = obj["load_bearing_capacity"].toString();

            qDebug().noquote() << QString("- %1 (%2, Load: %3)").arg(type, dimension, load);
        }
    }
}

void MainWindow::updatePalletInfo(const QString &name) {
    for (const QJsonValue &value : palletArray) {
        QJsonObject obj = value.toObject();
        if (obj["type"].toString().toLower().contains(name.toLower())) {
            QString info = QString("Pallet type: %1\nDimension: %2\nLoad-bearing capacity: %3\nExtra load: %4\nDead "
                                   "load: %5\nStandard: %6\nApplication: %7")
                               .arg(obj["type"].toString())
                               .arg(obj["dimension"].toString())
                               .arg(obj["load_bearing_capacity"].toString())
                               .arg(obj["extra_load"].toString())
                               .arg(obj["dead_load"].toString())
                               .arg(obj["technical_standard"].toString())
                               .arg(obj["application"].toString());

            emit palletInfoUpdated(info);
            return;
        }
    }

    qDebug() << DEBUG_PREFIX << "No pallet data found.";
}

void MainWindow::onFullScreen3DWindowClosed() {
    qDebug() << DEBUG_PREFIX << "Full Screen 3D View closed.";
}