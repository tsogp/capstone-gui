#ifndef __MAINWINDOW_H__
#define __MAINWINDOW_H__

#include "fullscreen3dwindow.h"
#include <QQmlApplicationEngine>
#include <QPointer>
#include <QObject>

class MainWindow : public QQmlApplicationEngine {
    Q_OBJECT
public:
    MainWindow();

    Q_INVOKABLE void openFullScreen3DWindow(const QString &message);
    void loadMainQml();
private slots:
    void onFullScreen3DWindowClosed();

private:
    FullScreen3DWindow* m_secondWindow;
};

#endif // __MAINWINDOW_H__