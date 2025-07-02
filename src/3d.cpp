#include "3d.h"
#include <QDebug>
#include <QMetaObject>
#include <QQmlComponent>
#include <QQmlContext>
#include <QRandomGenerator>
#include <qrandom.h>
#include <qvectornd.h>

ThreeDSpaceView::ThreeDSpaceView(QQmlContext *contextPtr, QObject *parent) : QObject(parent) {
    contextPtr->setContextProperty("threeDSpaceView", this);
}

QVector3D ThreeDSpaceView::newBoxPosition() const {
    return m_newBoxPosition;
}

void ThreeDSpaceView::setNewBoxPosition(const QVector3D &position) {
    if (m_newBoxPosition != position) {
        m_newBoxPosition = position;
        emit newBoxPositionChanged();
    }
}

QVector3D ThreeDSpaceView::newBoxRotation() const {
    return m_newBoxRotation;
}

void ThreeDSpaceView::setNewBoxRotation(const QVector3D &rotation) {
    if (m_newBoxRotation != rotation) {
        m_newBoxRotation = rotation;
        emit newBoxRotationChanged();
    }
}

QVector3D ThreeDSpaceView::newBoxScaleFactor() const {
    return m_newBoxScaleFactor;
}

void ThreeDSpaceView::setNewBoxScaleFactor(const QVector3D &scaleFactor) {
    if (m_newBoxScaleFactor != scaleFactor) {
        m_newBoxScaleFactor = scaleFactor;
        emit newBoxRotationChanged();
    }
}

void ThreeDSpaceView::genCoordinatesForNextBox() {
    // TODO: create actual logic
    int xVal = QRandomGenerator::global()->bounded(0, 20);
    int yVal = QRandomGenerator::global()->bounded(0, 20);
    int zVal = QRandomGenerator::global()->bounded(0, 20);
    float scale = QRandomGenerator::global()->bounded(1, 3);

    setNewBoxPosition(QVector3D(xVal, yVal, zVal));
    setNewBoxRotation(m_newBoxRotation);
    setNewBoxScaleFactor(QVector3D(scale, scale, scale));
}