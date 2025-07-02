#ifndef __3D_H__
#define __3D_H__

#include "boxdata.h"
#include <QObject>
#include <QPointer>
#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <QVector3D>
#include <qqmlcontext.h>
#include <qtmetamacros.h>

class ThreeDSpaceView : public QObject {
    Q_OBJECT

public:
    explicit ThreeDSpaceView(QQmlContext *contextPtr, QObject *parent = nullptr);

public slots:
    void genCoordinatesForNextBox();
    BoxData getNewBox();

private:
    BoxData m_newBox;
};

#endif // __3D_H__
