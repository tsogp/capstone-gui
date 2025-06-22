#ifndef __3D_H__
#define __3D_H__

#include <QObject>
#include <QPointer>
#include <QQmlApplicationEngine>
#include <QQuickItem>

class ThreeDSpaceView : public QObject {
    Q_OBJECT
public slots:
    QString currentModelSource() const;
    void setCurrentModelSource(const QString &src);

public:
    ThreeDSpaceView();

    void setRootObject(QObject *root);

private:
    QPointer<QObject> m_root;
};

#endif // __3D_H__
