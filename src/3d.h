#ifndef __3D_H__
#define __3D_H__

#include <QObject>
#include <QPointer>
#include <QString>
#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <qobject.h>

class ThreeDSpaceView : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentModelSource READ currentModelSource WRITE setCurrentModelSource NOTIFY currentModelSourceChanged)

public slots:
    QString currentModelSource() const;
    void setCurrentModelSource(const QString &src);

public:
    ThreeDSpaceView(QQmlEngine *engine);

    void setRootObject(QObject *root);

signals:
    void currentModelSourceChanged(const QString &src);

private:
    QPointer<QObject> m_root;
    QString m_currentModelSource;
};

#endif // __3D_H__
