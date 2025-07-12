#ifndef __3D_H__
#define __3D_H__

#include "boxdata.h"
#include <QObject>
#include <QPointer>
#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <QStack>
#include <QString>
#include <QVector3D>
#include <qqmlcontext.h>
#include <qtmetamacros.h>
#include <qvectornd.h>

class ThreeDSpaceView : public QObject {
    Q_OBJECT

    Q_PROPERTY(
        QString currentModelSource READ currentModelSource WRITE setCurrentModelSource NOTIFY currentModelSourceChanged)
    Q_PROPERTY(QVector2D rotationDelta READ rotationDelta WRITE setRotationDelta NOTIFY rotationDeltaChanged)
    Q_PROPERTY(float zoomLevel READ zoomLevel WRITE setZoomLevel NOTIFY zoomLevelChanged)
    Q_PROPERTY(float zLength READ zLength WRITE setZLength NOTIFY zLengthChanged)
public slots:
    QString currentModelSource() const;
    QVector2D rotationDelta() const;
    float zoomLevel() const;
    float zLength() const;
    void setCurrentModelSource(const QString &src);
    void setRotationDelta(const QVector2D &rotationDelta);
    void setZoomLevel(float value);
    void setZLength(float zLength);

public:
    explicit ThreeDSpaceView(QQmlContext *contextPtr, QObject *parent = nullptr);
    ~ThreeDSpaceView();

public slots:
    BoxData getNewBox();
    QVariantList getBoxes();
signals:
    void currentModelSourceChanged(const QString &src);
    void rotationDeltaChanged();
    void zoomLevelChanged();
    void zLengthChanged();

private:
    QStack<BoxData> m_boxes;
    QString m_currentModelSource;
    QVector2D m_rotationDelta;
    float m_zoomLevel = 1.0;
    float m_zLength;

    void readSettings();
    void writeSettings();
};

#endif // __3D_H__
