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

public slots:
    BoxData getNewBox();
    QVariantList getBoxes();
signals:
    void currentModelSourceChanged(const QString &src);

private:
    QStack<BoxData> m_boxes;
    QString m_currentModelSource;
};

#endif // __3D_H__
