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

class ThreeDSpaceView : public QObject {
    Q_OBJECT
    Q_PROPERTY(
        QString currentModelSource READ currentModelSource WRITE setCurrentModelSource NOTIFY currentModelSourceChanged)

public slots:
    QString currentModelSource() const;
    void setCurrentModelSource(const QString &src);

public:
    explicit ThreeDSpaceView(QQmlContext *contextPtr, QObject *parent = nullptr);
    void setBoxes(const QVector<BoxData> &boxes);

public slots:
    BoxData getNewBox();
    QVariantList getSpawnedBoxes();
signals:
    void currentModelSourceChanged(const QString &src);

private:
    QVector<BoxData> m_boxes;
    QStack<BoxData> m_spawnedBoxes;
    QString m_currentModelSource;
    int m_currentBoxId = 0; // Reference for new boxes
};

#endif // __3D_H__
