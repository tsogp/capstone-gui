#include "mainwindow.h"
#include "3d.h"
#include "boxdata.h"
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
#include <qtmetamacros.h>
#include <QTimer>

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

    connect(&m_networkHelper, &NetworkHelper::requestFinished,
            this, [this](const QJsonObject &response) {
                m_isRequestInProgress = false;
                emit isRequestInProgressChanged();

                m_serverResponse = response;
                emit serverResponseChanged();
                if (m_3dView != nullptr) {
                    m_3dView->processOutputBoxesJson(response);
                }

                qDebug() << "Server placed_boxes:" << response["placed_boxes"];
                qDebug() << "Server unplaced_boxes:" << response["unplaced_boxes"];
            });

    connect(&m_networkHelper, &NetworkHelper::requestError,
            this, [this](const QString &error) {
                m_isRequestInProgress = false;
                emit isRequestInProgressChanged();
                m_jsonErrorMessage = "Network error: " + error;
                qDebug() << m_jsonErrorMessage;
                emit jsonErrorMessageChanged();
            });
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

QString MainWindow::getRawJson() const {
    return m_rawJson;
}

QString MainWindow::getValidBoxesSummary() const {
    QString summary;
    for (const auto &box : m_inputBoxes) {
        summary += QString("Box %1: %2x%3x%4, weight %5, maxLoad %6\n")
                       .arg(box.m_id)
                       .arg(box.m_dimensions.y())
                       .arg(box.m_dimensions.x())
                       .arg(box.m_dimensions.z())
                       .arg(box.m_weight)
                       .arg(box.m_maxLoad);
    }
    return summary;
}

QString MainWindow::getInvalidBoxesSummary() const {
    if (m_invalidBoxes.isEmpty())
        return "No invalid boxes found.";

    QString summary;
    for (int i = 0; i < m_invalidBoxes.size(); ++i) {
        summary += QString("Invalid Box %1: %2\n").arg(i).arg(m_invalidBoxes[i]);
    }
    return summary;
}

void MainWindow::processBoxesJsonFile(const QUrl &fileUrl) {
    QString path = fileUrl.toLocalFile();

    auto fail = [&](const QString &msg) {
        m_jsonErrorMessage = msg;
        m_isJsonLoaded = false;
        emit jsonErrorMessageChanged();
        emit isJsonLoadedChanged();
        qWarning() << "JSON error:" << msg;
    };

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        fail("Cannot open file: " + path);
        return;
    }

    QJsonParseError error;
    QByteArray data = file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    file.close();

    if (error.error != QJsonParseError::NoError) {
        fail("JSON parse error: " + error.errorString());
        return;
    }
    if (!doc.isObject()) {
        fail("Incorrect format: JSON is not an object.");
        return;
    }

    QJsonObject root = doc.object();
    if (!root.contains("boxes") || !root["boxes"].isArray()) {
        fail("Incorrect format: Missing or invalid 'boxes' array.");
        return;
    }

    QJsonArray boxArray = root["boxes"].toArray();
    QList<QString> invalidBoxes;
    for (const QJsonValue &val : boxArray) {
        if (!val.isObject()) {
            invalidBoxes.append(QStringLiteral("{ /* Not an object */ }"));
            continue;
        }

        QJsonObject obj = val.toObject();
        bool ok = obj.contains("id") &&
                  obj.contains("w") &&
                  obj.contains("l") &&
                  obj.contains("h") &&
                  obj.contains("weight") &&
                  obj.contains("max_load");

        if (!ok) {
            invalidBoxes.append(QString::fromUtf8(QJsonDocument(obj).toJson(QJsonDocument::Compact)));
        }
    }

    if (!invalidBoxes.isEmpty()) {
        fail(QStringLiteral("Invalid box entries: %1").arg(invalidBoxes.join(", ")));
        return;
    }

    m_rawJson = QString::fromUtf8(data);
    m_jsonErrorMessage.clear();
    m_isJsonLoaded = true;
    emit jsonErrorMessageChanged();
    emit isJsonLoadedChanged();

    m_isRequestInProgress = true;
    emit isRequestInProgressChanged();
    qDebug() << "Sending request";

    QJsonObject requestJson;
    QJsonObject palletType;
    palletType["w"] = 80;
    palletType["l"] = 120;
    palletType["h"] = 144;
    palletType["max_total_load"] = 1000;

    requestJson["pallet_type"] = palletType;
    requestJson["boxes"] = root["boxes"];
    requestJson["generations"] = 1;

    QTimer::singleShot(0, this, [=]() {
        m_networkHelper.sendPutRequest("http://127.0.0.1:8000/calculate_placement", requestJson);
    });
}

bool MainWindow::isJsonLoaded() const {
    return m_isJsonLoaded;
}

void MainWindow::startSimulation() {
    // Assuming the simulation starts, and algorithm begins
    m_hasSimulationStarted = true;
    emit simulationStarted();
}

bool MainWindow::isRequestInProgress() const {
    return m_isRequestInProgress;
}

bool MainWindow::hasSimulationStarted() const {
    return m_hasSimulationStarted;
}

void MainWindow::updateBoxInfo(const QString &boxInfo) {
    // TODO: Finishing touches to display more detailed box info in the UI
    qDebug() << DEBUG_PREFIX << "Box info updated";
    emit boxInfoUpdated(boxInfo);
}

void MainWindow::clearBoxInfo() {
    emit boxInfoCleared();
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