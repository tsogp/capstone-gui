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
    QVector3D dimensions(100, 100, 100);

    BoxData newBox(dimensions, position, rotation, scaleFactor);
    m_boxes.push(newBox);

    return newBox;
}