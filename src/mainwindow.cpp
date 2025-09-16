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
#include <cstddef>
#include <memory>
#include <qdebug.h>
#include <qobject.h>
#include <qtmetamacros.h>
#include <QTimer>

#define MAINWINDOW_URL "qrc:/FullScreen3DView/qml/Mainscreen.qml"
#define WINDOW_NAME "MainWindow"
#define DEBUG_PREFIX "[" WINDOW_NAME "]:"
#define serverURL "http://127.0.0.1:8000"

MainWindow::MainWindow() {
    loadPalletsJson();

    m_context = rootContext();
    m_context->setContextProperty("mainWindow", this);

    qDebug() << DEBUG_PREFIX << "In constructor";

    m_secondWindow = new FullScreen3DWindow(this, m_context, this);
    m_3dView = std::make_unique<ThreeDSpaceView>(m_context, m_context);

    connect(m_secondWindow, &FullScreen3DWindow::closed, this, &MainWindow::onFullScreen3DWindowClosed);

    connect(&m_networkHelper, &NetworkHelper::jobStarted, this, [this](const QString &jobId) {
        m_isRequestInProgress = true;
        emit isRequestInProgressChanged();
        qDebug() << "Placement job started with ID:" << jobId;

        // Begin polling progress
        m_networkHelper.pollProgress(QString(serverURL), 2000);
    });

    connect(&m_networkHelper, &NetworkHelper::progressUpdated, this, [this](int progress, const QString &status) {
        setProgressValue(progress);
        emit progressValueChanged();
        qDebug() << "Progress:" << progress << "% Status:" << status;

        if (status == "done") {
            // Fetch final result automatically
            m_networkHelper.fetchResult(QString(serverURL));
            
            // Simulation starts, algorithm has finished
            m_hasSimulationStarted = true;
            emit simulationStarted();
        }
    });

    connect(&m_networkHelper, &NetworkHelper::jobFinished, this, [this](const QString &jobId) {
        m_isRequestInProgress = false;
        emit isRequestInProgressChanged();

        qDebug() << "Job finished with ID:" << jobId;
    });

    connect(&m_networkHelper, &NetworkHelper::resultReceived, this, [this](const QJsonObject &result) {
        m_serverResponse = result;
        emit serverResponseChanged();
        if (m_3dView != nullptr) {
            m_3dView->processOutputBoxesJson(result);
        }

        QString resultStats = QString("Generations: %1\nVolume utilization: %2\nGlobal air exposure ratio: %3\nCenter of gravity: %4\nFitness score: %5")
                          .arg(result["generations"].toInt())
                          .arg(result["volume_utilization"].toDouble())
                          .arg(result["global_air_exposure_ratio"].toDouble())
                          .arg(result["center_of_gravity"].toString())
                          .arg(result["fitness_score"].toDouble());
        emit resultStatsReceived(resultStats);

        qDebug() << "Server placed_boxes:" << result["placed_boxes"];
        qDebug() << "Server unplaced_boxes:" << result["unplaced_boxes"];
    });

    connect(&m_networkHelper, &NetworkHelper::requestError, this, [this](const QString &error) {
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

QString MainWindow::getInvalidBoxesSummary() const {
    if (m_invalidBoxes.isEmpty())
        return "No invalid boxes found.";

    QString summary;
    for (int i = 0; i < m_invalidBoxes.size(); ++i) {
        summary += QString("Invalid Box %1: %2\n").arg(i).arg(m_invalidBoxes[i]);
    }
    return summary;
}

void MainWindow::processBoxesManual(const QVariantList &boxes) {
    auto fail = [&](const QString &msg) {
        m_jsonErrorMessage = msg;
        m_isJsonLoaded = false;
        emit jsonErrorMessageChanged();
        emit isJsonLoadedChanged();
        qWarning() << "Manual JSON error:" << msg;
    };

    if (boxes.isEmpty()) {
        fail("No boxes provided.");
        return;
    }

    QJsonArray boxArray;
    int i = 1;
    for (const QVariant &v : boxes) {
        QJsonObject obj = v.toJsonObject();
        int box_amount = obj["amount"].toInt();

        for (int j = 0; j < box_amount; ++j) {
            bool ok = obj.contains("w") && obj.contains("l") && obj.contains("h") &&
                      obj.contains("weight") && obj.contains("max_load");
    
            obj["id"] = i++;
            obj.remove("amount");
    
            if (!ok) {
                fail("Invalid box entry: " + QString::fromUtf8(QJsonDocument(obj).toJson(QJsonDocument::Compact)));
                return;
            }
    
            // Append amount times if needed, or just push one entry
            boxArray.append(obj);
        }
    }

    QJsonObject root;
    root["boxes"] = boxArray;

    m_rawJson = QString::fromUtf8(QJsonDocument(root).toJson(QJsonDocument::Compact));
    m_jsonErrorMessage.clear();
    m_isJsonLoaded = true;
    emit jsonErrorMessageChanged();
    emit isJsonLoadedChanged();

    emit isRequestInProgressChanged();
    QJsonObject palletType;

    QVector3D palletData = m_3dView->palletData();
    palletType["w"] = palletData.z();
    palletType["l"] = palletData.x();
    
    // TODO: pass height and max total load
    palletType["h"] = 144;
    palletType["max_total_load"] = 1000;

    requestJson["pallet_type"] = palletType;
    requestJson["boxes"] = boxArray;
    requestJson["generations"] = 1;
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
        bool ok = obj.contains("id") && obj.contains("w") && obj.contains("l") && obj.contains("h") &&
                  obj.contains("weight") && obj.contains("max_load");

        m_inputBoxes.append(obj);

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

    emit isRequestInProgressChanged();

    QJsonObject palletType;
    QVector3D palletData = m_3dView->palletData();
    palletType["w"] = palletData.z();
    palletType["l"] = palletData.x();
    
    // TODO: pass height and max total load
    palletType["h"] = 144;
    palletType["max_total_load"] = 1000;

    requestJson["pallet_type"] = palletType;
    requestJson["boxes"] = root["boxes"];
    requestJson["generations"] = 1;


}

bool MainWindow::isJsonLoaded() const {
    return m_isJsonLoaded;
}

void MainWindow::startSimulation() {
    qDebug() << "Sending request";
    // Start algorithm, and process the placement of boxes
    QTimer::singleShot(0, this, [=]() {
        m_networkHelper.sendPostRequest("http://127.0.0.1:8000/calculate_placement", requestJson);
    });
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

void MainWindow::restartSimulation() {
    m_hasSimulationStarted = false;
    emit simulationStarted();

    m_isRequestInProgress = false;
    emit isRequestInProgressChanged();

    m_progressValue = 0;
    emit progressValueChanged();

    m_serverResponse = QJsonObject();
    emit serverResponseChanged();

    m_rawJson.clear();
    emit jsonErrorMessageChanged();

    m_isJsonLoaded = false;
    emit isJsonLoadedChanged();

    m_inputBoxes = QJsonArray();
    m_invalidBoxes.clear();

    requestJson = QJsonObject();

    emit clearMainScreen();

    if (m_3dView) {
        m_3dView->clearScene();
    }

    qDebug() << DEBUG_PREFIX << "Simulation state reset.";
}

void MainWindow::setProgressValue(int value) {
    if (m_progressValue != value) {
        m_progressValue = value;
        emit progressValueChanged();
    }
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