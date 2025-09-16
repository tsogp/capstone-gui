#include "3d.h"
#include "src/boxdata.h"
#include <QDebug>
#include <QMetaObject>
#include <QQmlComponent>
#include <QQmlContext>
#include <QRandomGenerator>
#include <algorithm>
#include <optional>
#include <qcontainerfwd.h>
#include <qdebug.h>
#include <qrandom.h>
#include <qsettings.h>
#include <qvariant.h>
#include <qvectornd.h>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>

#define WINDOW_NAME "3DWindow"
#define DEBUG_PREFIX "[" WINDOW_NAME "]:"

ThreeDSpaceView::ThreeDSpaceView(QQmlContext *contextPtr, QObject *parent) : QObject(parent) {
    contextPtr->setContextProperty("threeDSpaceView", this);
    readSettings();
    m_autoSpawnTimer.setInterval(2000);
    connect(&m_autoSpawnTimer, &QTimer::timeout, this, &ThreeDSpaceView::onAutoSpawnTimeout);
}

QString ThreeDSpaceView::currentModelSource() const {
    return m_currentModelSource;
}

QVector2D ThreeDSpaceView::rotationDelta() const {
    return m_rotationDelta;
}

QVector3D ThreeDSpaceView::palletData() const {
    return m_palletData; // 120, 9.8, 80
}

QVariantList ThreeDSpaceView::getSpawnedBoxes() {
    QVariantList list(m_spawnedBoxes.size());
    for (int i = 0; i < m_spawnedBoxes.size(); ++i) {
        list[i] = QVariant::fromValue(m_spawnedBoxes.at(i));
    }
    return list;
}

bool ThreeDSpaceView::autoMode() const {
    return m_autoMode;
}

void ThreeDSpaceView::processOutputBoxesJson(const QJsonObject &response) {
    if (!response.contains("placed_boxes") || !response["placed_boxes"].isArray()) {
        qWarning() << "Invalid response: no placed_boxes array.";
        return;
    }

    QJsonArray placedArray = response["placed_boxes"].toArray();
    QVector<BoxData> parsedOutputBoxes;

    for (const QJsonValue &val : placedArray) {
        if (!val.isObject()) {
            qWarning() << "Invalid placed_boxes entry (not an object)";
            continue;
        }

        QJsonObject obj = val.toObject();

        BoxData box(
            obj["id"].toInt(),
            obj["weight"].toDouble(),
            obj["max_load"].toDouble(),
            QVector3D(obj["y"].toDouble(), obj["z"].toDouble(), obj["x"].toDouble()),
            QVector3D(0, 0, 0),
            QVector3D(1, 1, 1),
            QVector3D(obj["l"].toDouble(), obj["h"].toDouble(), obj["w"].toDouble())
        );

        parsedOutputBoxes.append(box);
    }

    std::sort(parsedOutputBoxes.begin(), parsedOutputBoxes.end(), [](const BoxData& a, const BoxData& b) { 
        return a.m_position.y() < b.m_position.y();  
    });

    setOutputBoxes(parsedOutputBoxes);
    qDebug() << "Done";
}

void ThreeDSpaceView::setOutputBoxes(const QVector<BoxData> &boxes) {
    m_outputBoxes = boxes;
    emit navigationChanged();
}

void ThreeDSpaceView::select3DBox(int boxId) {
    for (const BoxData &box : m_outputBoxes) {
        if (box.m_id == boxId) {
            QString info = QString("Box ID: %1\n"
                                   "Weight: %2\n"
                                   "Max Load: %3\n"
                                   "Position: (%4, %5, %6)\n"
                                   "Dimensions: (%7, %8, %9)")
                               .arg(box.m_id)
                               .arg(box.m_weight)
                               .arg(box.m_maxLoad)
                               .arg(box.m_position.x())
                               .arg(box.m_position.y())
                               .arg(box.m_position.z())
                               .arg(box.m_dimensions.x())
                               .arg(box.m_dimensions.y())
                               .arg(box.m_dimensions.z());
            emit updateBoxInfo(info);
            qDebug() << DEBUG_PREFIX << "Send info from 3D view for box ID:" << boxId;
            return;  // Exit after finding the box
        }
    }
    qDebug() << DEBUG_PREFIX << "No box found with ID:" << boxId;
}

void ThreeDSpaceView::spawnBoxManual() {
    emit spawnBoxRequested();
}

void ThreeDSpaceView::despawnNewestBox() {
    if (!m_spawnedBoxes.isEmpty()) {
        m_spawnedBoxes.pop();
        emit despawnBoxRequested();
        emit navigationChanged();
    }
}

void ThreeDSpaceView::onAutoSpawnTimeout() {
    emit spawnBoxRequested();
}

bool ThreeDSpaceView::canGoPrevious() const {
    return !m_spawnedBoxes.isEmpty();
}

bool ThreeDSpaceView::canGoNext() const {
    return !m_outputBoxes.isEmpty() && m_outputBoxes.size() > m_spawnedBoxes.size();
}

QVariant ThreeDSpaceView::getNewBox() {
    if (m_outputBoxes.size() == m_spawnedBoxes.size()) {
        setAutoMode(false);
        emit navigationChanged();
        return QVariant();
    }
    qDebug() << m_outputBoxes.size() << ' ' << m_spawnedBoxes.size() << '\n';

    BoxData jsonBox = m_outputBoxes.at(m_spawnedBoxes.size());
    double scaleFactor = 0.01; // From IRL to 3D space, 100:1
    // Convert box dimensions to standard 3D space units
    /* NOTE:
        There is an issue with the scale factors + 3D model that results in gaps during rendering.
        - The QVector3D does not store enough decimal places to make the final result closer to the expected dimensions.
        - There is a gap between the rendered boxes regardless of the scale factor (check spawn coordinates).
    */
    QVector3D boxSize = QVector3D((jsonBox.m_dimensions.x() * scaleFactor),
                                  (jsonBox.m_dimensions.y() * scaleFactor),
                                  (jsonBox.m_dimensions.z() * scaleFactor));
    QVector3D position = jsonBox.m_position;

    // Calculate the displacement relative to the pallet
    double xVal = position.x() - (m_palletData.x() / 2) + (jsonBox.m_dimensions.x() / 2); // Up and down
    double yVal = position.y() + (m_palletData.y() / 2) + (jsonBox.m_dimensions.y() / 2); // In and out
    double zVal = position.z() - (m_palletData.z() / 2) + (jsonBox.m_dimensions.z() / 2); // Left and right
    QVector3D rotation(0, 0, 0);
    QVector3D boxDisplace(xVal, yVal, zVal);

    // TODO: after algo integration, these variables should not need to be assigned
        BoxData newBox = BoxData(jsonBox.m_id,
                                jsonBox.m_weight,
                                jsonBox.m_maxLoad,
                                boxDisplace,
                                rotation,
                                boxSize,
                                jsonBox.dimensions()
                            );
    m_spawnedBoxes.push(newBox);

    if (m_spawnedBoxes.size() == 1) {
        emit navigationChanged();
    }
    
    return QVariant::fromValue(newBox);;
}

void ThreeDSpaceView::setCurrentModelSource(const QString &src) {
    if (m_currentModelSource != src) {
        QString path = QString("qrc:/FullScreen3DView/assets/models/%1/%2Pallet.qml").arg(src.toLower(), src);
        m_currentModelSource = path;
        emit currentModelSourceChanged(path);

        qDebug() << "currentModelSource updated to:" << src;
    }
}

void ThreeDSpaceView::setRotationDelta(const QVector2D &rotationDelta) {
    if (m_rotationDelta != rotationDelta) {
        m_rotationDelta = rotationDelta;
        emit rotationDeltaChanged();
    }
}

void ThreeDSpaceView::writeSettings() {
    QSettings settings;
    settings.beginGroup(WINDOW_NAME);
    settings.setValue("rotationDelta", m_rotationDelta);
    settings.setValue("zoomLevel", m_zoomLevel);
    settings.endGroup();
}

void ThreeDSpaceView::readSettings() {
    QSettings settings;

    settings.beginGroup(WINDOW_NAME);
    m_rotationDelta = qvariant_cast<QVector2D>(settings.value("rotationDelta", QVector2D(0, 0)));
    m_zoomLevel = settings.value("zoomLevel", 1.0).toFloat();
    settings.endGroup();
}

float ThreeDSpaceView::zoomLevel() const {
    return m_zoomLevel;
}

void ThreeDSpaceView::setZoomLevel(float value) {
    if (m_zoomLevel != value) {
        m_zoomLevel = value;
        emit zoomLevelChanged();
    }
}

void ThreeDSpaceView::setPalletData(const QVector3D &palletData) {
    if (m_palletData != palletData) {
        m_palletData = palletData;
        emit palletDataChanged();
    }
}

void ThreeDSpaceView::setAutoMode(bool enabled) {
    if (enabled) {
        m_autoSpawnTimer.start();
        m_autoMode = true;
    } else {
        m_autoSpawnTimer.stop();
        m_autoMode = false;
    }

    emit autoModeChanged();
}

void ThreeDSpaceView::clearScene() {
    m_spawnedBoxes.clear();
    m_outputBoxes.clear();
    emit clear3DScene();
    emit navigationChanged();
}

ThreeDSpaceView::~ThreeDSpaceView() {
    writeSettings();
}