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
#include <qvariant.h>
#include <qvectornd.h>

#define WINDOW_NAME "3DWindow"
#define DEBUG_PREFIX "[" WINDOW_NAME "]:"

ThreeDSpaceView::ThreeDSpaceView(QQmlContext *contextPtr, QObject *parent) : QObject(parent) {
    contextPtr->setContextProperty("threeDSpaceView", this);
}

QString ThreeDSpaceView::currentModelSource() const {
    return m_currentModelSource;
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
    int xVal = QRandomGenerator::global()->bounded(0, 20);
    int yVal = QRandomGenerator::global()->bounded(0, 20);
    int zVal = QRandomGenerator::global()->bounded(0, 20);
    double scale = std::max(1.0, QRandomGenerator::global()->generateDouble() * 3.0);

    QVector3D position(xVal, yVal, 35);
    QVector3D rotation(0, 0, 0);
    QVector3D scaleFactor(scale, scale, scale);
    
    //TODO: after algo integration, these variables should not need to be assigned
    BoxData newBox = m_boxes.at(m_currentBoxId);
    newBox.m_position = position;
    newBox.m_rotation = rotation;
    newBox.m_scaleFactor = scaleFactor;
    m_spawnedBoxes.push(newBox);
    m_currentBoxId++; // Increment for next box

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