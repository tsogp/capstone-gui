#ifndef __FULLSCREEN3DWINDOW_H__
#define __FULLSCREEN3DWINDOW_H__

#include <QObject>
#include <QPointer>
#include <QQmlApplicationEngine>
#include <QQuickWindow>

class FullScreen3DWindow : public QObject {
    Q_OBJECT
public:
    FullScreen3DWindow(QQmlEngine *engine, QObject *parent = nullptr);

    void show(const QString &data);

signals:
    void closed();
    void finished(const QString &result);

private:
    QPointer<QQuickWindow> m_window;
    QQmlEngine *m_engine;

private slots:
    void onWindowClosed();
};

#endif // __FULLSCREEN3DWINDOW_H__