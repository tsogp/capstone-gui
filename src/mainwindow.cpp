#include "mainwindow.h"
#include "3d.h"
#include "fullscreen3dwindow.h"
#include <QDebug>
#include <QFile>
#include <QJsonObject>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickWindow>
#include <memory>
#include <qdebug.h>
#include <qobject.h>

#define MAINWINDOW_URL "qrc:/FullScreen3DView/qml/Mainscreen.qml"
#define WINDOW_NAME "MainWindow"
#define DEBUG_PREFIX "[" WINDOW_NAME "]:"

MainWindow::MainWindow() {
    loadPalletsJson();

    m_context = rootContext();
    m_context->setContextProperty("mainWindow", this);

    qDebug() << DEBUG_PREFIX << "In constructor";

    m_secondWindow = new FullScreen3DWindow(this, m_context, this);
    m_3dView = std::make_unique<ThreeDSpaceView>(m_context, m_context);

    connect(m_secondWindow, &FullScreen3DWindow::closed, this, &MainWindow::onFullScreen3DWindowClosed);
}

void MainWindow::loadMainQml() {
    load(QUrl(MAINWINDOW_URL));
}

void MainWindow::openFullScreen3DWindow(const QString &message) {
    if (!m_3dView) {
        return;
    }

    qDebug() << DEBUG_PREFIX << "Full Screen 3D View opened.";
    m_isFullScreenViewOpen = true;
    emit isFullScreenViewOpenChanged();

    if (m_secondWindow == nullptr) {
        m_secondWindow = new FullScreen3DWindow(this, m_context, this);
        connect(m_secondWindow, &FullScreen3DWindow::closed, this, &MainWindow::onFullScreen3DWindowClosed);
    }

    m_secondWindow->setThreeDView(std::move(m_3dView));
    m_secondWindow->show(message);
}

void MainWindow::loadPalletsJson() {
    QFile file(":/FullScreen3DView/data/pallet.json");
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
            m_3dView->setPalletData(
                QVector3D(obj["xLength"].toDouble(), obj["yLength"].toDouble(), obj["zLength"].toDouble()));

            m_3dView->setCurrentModelSource(name);

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
    if (m_secondWindow) {
        m_3dView = std::move(m_secondWindow->takeThreeDView());

        m_secondWindow->deleteLater();
        m_secondWindow = nullptr;
    }

    qDebug() << DEBUG_PREFIX << "Full Screen 3D View closed.";
    m_isFullScreenViewOpen = false;
    emit isFullScreenViewOpenChanged();
}