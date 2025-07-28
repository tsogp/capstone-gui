#include "3d.h"
#include "src/boxdata.h"
#include <QDebug>
#include <QMetaObject>
#include <QQmlComponent>
#include <QQmlContext>
#include <QRandomGenerator>
#include <algorithm>
#include <qcontainerfwd.h>
#include <qrandom.h>
#include <qsettings.h>
#include <qvariant.h>
#include <qvectornd.h>

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

void ThreeDSpaceView::setBoxes(const QVector<BoxData> &boxes) {
    m_boxes = boxes;
}

BoxData ThreeDSpaceView::getNewBox() {
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
    BoxData newBox = BoxData(m_spawnedBoxes.size(), 12, 12, position, rotation, scaleFactor);
    m_spawnedBoxes.push(newBox);

    return newBox;
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