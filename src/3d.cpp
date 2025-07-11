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

QVariantList ThreeDSpaceView::getBoxes() {
    QVariantList list(m_boxes.size());
    for (int i = 0; i < m_boxes.size(); ++i) {
        list[i] = QVariant::fromValue(m_boxes.at(i));
    }
    return list;
}

BoxData ThreeDSpaceView::getNewBox() {
    // TODO: create actual spwaning logic with collision detection
    int xVal = QRandomGenerator::global()->bounded(0, 20);
    int yVal = QRandomGenerator::global()->bounded(0, 20);
    int zVal = QRandomGenerator::global()->bounded(0, 20);
    double scale = std::max(1.0, QRandomGenerator::global()->generateDouble() * 3.0);

    QVector3D position(xVal, yVal, 35);
    QVector3D rotation(0, 0, 0);
    QVector3D scaleFactor(scale, scale, scale);

    BoxData newBox(position, rotation, scaleFactor);
    m_boxes.push(newBox);

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

ThreeDSpaceView::~ThreeDSpaceView() {
    writeSettings();
}