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
#include <qcontainerfwd.h>
#include <qqmlcontext.h>
#include <qtimer.h>
#include <qtmetamacros.h>
#include <qvectornd.h>

class ThreeDSpaceView : public QObject {
    Q_OBJECT

    Q_PROPERTY(
        QString currentModelSource READ currentModelSource WRITE setCurrentModelSource NOTIFY currentModelSourceChanged)
    Q_PROPERTY(QVector2D rotationDelta READ rotationDelta WRITE setRotationDelta NOTIFY rotationDeltaChanged)
    Q_PROPERTY(float zoomLevel READ zoomLevel WRITE setZoomLevel NOTIFY zoomLevelChanged)
    Q_PROPERTY(QVector3D palletData READ palletData CONSTANT NOTIFY palletDataChanged)
    Q_PROPERTY(bool autoMode READ autoMode WRITE setAutoMode NOTIFY autoModeChanged)
    Q_PROPERTY(bool canGoPrevious READ canGoPrevious NOTIFY navigationChanged)
    Q_PROPERTY(bool canGoNext READ canGoNext NOTIFY navigationChanged)
    
public slots:
    QString currentModelSource() const;
    QVector2D rotationDelta() const;
    float zoomLevel() const;
    QVector3D palletData() const;
    void setCurrentModelSource(const QString &src);
    void setRotationDelta(const QVector2D &rotationDelta);
    void setZoomLevel(float value);
    void setPalletData(const QVector3D &palletData);
    void processOutputBoxesJson(const QJsonObject &response);
    QVariantList getSpawnedBoxes();
    QVariant getNewBox();
    void select3DBox(int boxId);
    bool autoMode() const;
    void onAutoSpawnTimeout();
    bool canGoPrevious() const;
    bool canGoNext() const;

public:
    explicit ThreeDSpaceView(QQmlContext *contextPtr, QObject *parent = nullptr);
    void setOutputBoxes(const QVector<BoxData> &outputBoxes);
    Q_INVOKABLE void setAutoMode(bool enabled);
    Q_INVOKABLE void spawnBoxManual();
    Q_INVOKABLE void despawnNewestBox();
    void clearScene();
    ~ThreeDSpaceView();

signals:
    void currentModelSourceChanged(const QString &src);
    void rotationDeltaChanged();
    void zoomLevelChanged();
    void palletDataChanged();
    void updateBoxInfo(const QString &boxInfo);
    void clearBoxInfo();
    void autoModeChanged();
    void spawnBoxRequested();
    void despawnBoxRequested();
    void navigationChanged();
    void clear3DScene();

private:
    QVector<BoxData> m_outputBoxes;
    QStack<BoxData> m_spawnedBoxes;
    QVector3D m_palletData;
    QString m_currentModelSource;
    QVector2D m_rotationDelta;
    float m_zoomLevel = 1.0;
    QTimer m_autoSpawnTimer;
    bool m_autoMode = false;

    void readSettings();
    void writeSettings();
};

#endif // __3D_H__
