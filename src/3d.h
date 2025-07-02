#ifndef __3D_H__
#define __3D_H__

#include <QObject>
#include <QPointer>
#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <qqmlcontext.h>
#include <qtmetamacros.h>
#include <qvectornd.h>

class ThreeDSpaceView : public QObject {
    Q_OBJECT

    Q_PROPERTY(QVector3D newBoxPosition READ newBoxPosition WRITE setNewBoxPosition NOTIFY newBoxPositionChanged)
    Q_PROPERTY(QVector3D newBoxRotation READ newBoxRotation WRITE setNewBoxRotation NOTIFY newBoxRotationChanged)
    Q_PROPERTY(
        QVector3D newBoxScaleFactor READ newBoxScaleFactor WRITE setNewBoxScaleFactor NOTIFY newBoxScaleFactorChanged)
public:
    explicit ThreeDSpaceView(QQmlContext *contextPtr, QObject *parent = nullptr);

    QVector3D newBoxPosition() const;
    void setNewBoxPosition(const QVector3D &position);
    QVector3D newBoxRotation() const;
    void setNewBoxRotation(const QVector3D &rotation);
    QVector3D newBoxScaleFactor() const;
    void setNewBoxScaleFactor(const QVector3D &rotation);
public slots:
    void genCoordinatesForNextBox();

signals:
    void newBoxPositionChanged();
    void newBoxRotationChanged();
    void newBoxScaleFactorChanged();

private:
    QVector3D m_newBoxPosition;
    QVector3D m_newBoxRotation;
    QVector3D m_newBoxScaleFactor;
};

#endif // __3D_H__
