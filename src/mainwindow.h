#ifndef __MAINWINDOW_H__
#define __MAINWINDOW_H__

#include "fullscreen3dwindow.h"
#include <QJsonArray>
#include <QObject>
#include <QPointer>
#include <QQmlApplicationEngine>
#include <qtmetamacros.h>

class MainWindow : public QQmlApplicationEngine {
    Q_OBJECT
public:
    MainWindow();

    Q_INVOKABLE void openFullScreen3DWindow(const QString &message);
    Q_INVOKABLE void updatePalletInfo(const QString &name);
    void loadMainQml();

signals:
    void palletInfoUpdated(const QString &info);

private:
    QJsonArray palletArray;
    void loadPalletsJson();
    FullScreen3DWindow *m_secondWindow;

private slots:
    void onFullScreen3DWindowClosed();
};

#endif // __MAINWINDOW_H__