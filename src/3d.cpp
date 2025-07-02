#include "3d.h"
#include <QDebug>
#include <QMetaObject>
#include <QQmlComponent>
#include <QQmlContext>
#include <QRandomGenerator>
#include <algorithm>
#include <qrandom.h>
#include <qvectornd.h>

#define WINDOW_NAME "3DWindow"
#define DEBUG_PREFIX "[" WINDOW_NAME "]:"

ThreeDSpaceView::ThreeDSpaceView(QQmlContext *contextPtr, QObject *parent) : QObject(parent) {
    contextPtr->setContextProperty("threeDSpaceView", this);
}

void ThreeDSpaceView::genCoordinatesForNextBox() {
    // TODO: create actual logic
    int xVal = QRandomGenerator::global()->bounded(0, 20);
    int yVal = QRandomGenerator::global()->bounded(0, 20);
    int zVal = QRandomGenerator::global()->bounded(0, 20);
    double scale = std::max(1.0, QRandomGenerator::global()->generateDouble() * 3.0);

    QVector3D position(xVal, yVal, 35);
    QVector3D rotation(0, 0, 0);
    QVector3D scaleFactor(scale, scale, scale);
    QVector3D dimensions(100, 100, 100);

    m_newBox.m_position = position;
    m_newBox.m_rotation = rotation;
    m_newBox.m_scaleFactor = scaleFactor;
    m_newBox.m_dimensions = dimensions;
}

BoxData ThreeDSpaceView::getNewBox() {
    genCoordinatesForNextBox();
    return m_newBox;
}