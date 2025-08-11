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
}

QString ThreeDSpaceView::currentModelSource() const {
    return m_currentModelSource;
}

QVector2D ThreeDSpaceView::rotationDelta() const {
    return m_rotationDelta;
}

QVector3D ThreeDSpaceView::palletData() const {
    return m_palletData;
}

QVariantList ThreeDSpaceView::getSpawnedBoxes() {
    QVariantList list(m_spawnedBoxes.size());
    for (int i = 0; i < m_spawnedBoxes.size(); ++i) {
        list[i] = QVariant::fromValue(m_spawnedBoxes.at(i));
    }
    return list;
}

// TODO: Revise after integration with the algorithm
void ThreeDSpaceView::processOutputBoxesJsonFile(const QUrl &fileUrl) {
    // Assumes the returned file is a valid JSON file containing 
    // an array of BoxData objects, thus no error handling for file existence
    QFile file(fileUrl.toLocalFile());
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning("Could not open JSON file.");
        return;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "JSON Parse Error:" << parseError.errorString();
        return;
    }

    QVector<BoxData> parsedOutputBoxes;

    for (const QJsonValue &val : doc.array()) {
        QJsonObject obj = val.toObject();
        
        BoxData box =
            BoxData(obj["id"].toInt(),
                    obj["weight"].toDouble(),
                    obj["max_load"].toInt(),
                    QVector3D(obj["x"].toInt(), obj["y"].toInt(), obj["z"].toInt()), // Placeholder for position
                    QVector3D(0, 0, 0),                                              // Placeholder for rotation
                    QVector3D(1, 1, 1),                                              // Placeholder for scale factor
                    QVector3D(obj["l"].toInt(), obj["w"].toInt(), obj["h"].toInt()));

        parsedOutputBoxes.append(box);
    }

    setOutputBoxes(parsedOutputBoxes);
}

void ThreeDSpaceView::setOutputBoxes(const QVector<BoxData> &boxes) {
    m_outputBoxes = boxes;
}

void ThreeDSpaceView::select3DBox(int boxId) {
    if (boxId == -1) {

    }

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

QVariant ThreeDSpaceView::getNewBox() {
    if (m_outputBoxes.size() == m_spawnedBoxes.size()) {
        return QVariant();
    }
    // TODO: create actual spwaning logic with collision detection
    double xHalf = static_cast<double>(m_palletData.x() / 2);
    double zHalf = static_cast<double>(m_palletData.z() / 2);
    
    // Random value in range [-xHalf, +xHalf]
    double xVal = (QRandomGenerator::global()->generateDouble() * 2.0 - 1.0) * xHalf;
    double zVal = (QRandomGenerator::global()->generateDouble() * 2.0 - 1.0) * zHalf;
    // double scale = std::max(1.0, QRandomGenerator::global()->generateDouble() * 3.0);
    double scale = 1.0f;

    QVector3D position(xVal, -m_palletData.y(), zVal);
    QVector3D rotation(0, 0, 0);
    QVector3D scaleFactor(scale, scale, scale);
    
    // TODO: after algo integration, these variables should not need to be assigned
    qDebug() << m_outputBoxes.size() << ' ' << m_spawnedBoxes.size() << '\n';
    BoxData jsonBox = m_outputBoxes.at(m_spawnedBoxes.size());
    BoxData newBox = BoxData(jsonBox.m_id, jsonBox.m_weight, jsonBox.m_maxLoad, jsonBox.m_position, rotation, scaleFactor, jsonBox.dimensions());  m_spawnedBoxes.push(newBox);

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

ThreeDSpaceView::~ThreeDSpaceView() {
    writeSettings();
}