#ifndef __MAINWINDOW_H__
#define __MAINWINDOW_H__

#include "3d.h"
#include "fullscreen3dwindow.h"
#include <QJsonArray>
#include <QObject>
#include <QPointer>
#include <QQmlApplicationEngine>
#include <QScopedPointer>
#include <qtmetamacros.h>

class MainWindow : public QQmlApplicationEngine {
    Q_OBJECT
    Q_PROPERTY(bool isFullScreenViewOpen READ isFullScreenViewOpen NOTIFY isFullScreenViewOpenChanged)
public slots:
    void openFullScreen3DWindow(const QString &message);
    void updatePalletInfo(const QString &name);

public:
    MainWindow();

    void loadMainQml();
    bool isFullScreenViewOpen() const {
        return m_isFullScreenViewOpen;
    }

signals:
    void palletInfoUpdated(const QString &info);
    void isFullScreenViewOpenChanged();

private slots:
    void onFullScreen3DWindowClosed();

private:
    std::unique_ptr<ThreeDSpaceView> m_3dView;
    QPointer<QQmlContext> m_context;
    QPointer<FullScreen3DWindow> m_secondWindow;
    QJsonArray palletArray;
    bool m_isFullScreenViewOpen = false;

    void loadPalletsJson();
};


#endif // __MAINWINDOW_H__