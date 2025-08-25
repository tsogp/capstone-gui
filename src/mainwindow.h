#ifndef __MAINWINDOW_H__
#define __MAINWINDOW_H__

#include "3d.h"
#include "fullscreen3dwindow.h"
#include "networkhelper.h"
#include <QJsonArray>
#include <QObject>
#include <QPointer>
#include <QQmlApplicationEngine>
#include <QScopedPointer>
#include <qtmetamacros.h>

class MainWindow : public QQmlApplicationEngine {
    Q_OBJECT
    Q_PROPERTY(bool isFullScreenViewOpen READ isFullScreenViewOpen NOTIFY isFullScreenViewOpenChanged)
    Q_PROPERTY(QString jsonErrorMessage READ jsonErrorMessage NOTIFY jsonErrorMessageChanged)
    Q_PROPERTY(bool isJsonLoaded READ isJsonLoaded NOTIFY isJsonLoadedChanged)
    Q_PROPERTY(bool hasSimulationStarted READ hasSimulationStarted NOTIFY simulationStarted)
    Q_PROPERTY(bool isRequestInProgress READ isRequestInProgress NOTIFY isRequestInProgressChanged)
    Q_PROPERTY(int progressValue READ progressValue WRITE setProgressValue NOTIFY progressValueChanged)

public slots:
    void openFullScreen3DWindow(const QString &message);
    void updatePalletInfo(const QString &name);
    void processBoxesJsonFile(const QUrl &fileUrl);
    void processBoxesManual(const QVariantList &boxes);
    QString getRawJson() const;
    QString getInvalidBoxesSummary() const;
    bool isJsonLoaded() const;
    void startSimulation();
    bool hasSimulationStarted() const;
    bool isRequestInProgress() const;
    void updateBoxInfo(const QString &boxInfo);
    void clearBoxInfo();

public:
    MainWindow();

    void loadMainQml();
    bool isFullScreenViewOpen() const { return m_isFullScreenViewOpen; }
    const QJsonArray &inputBoxes() const { return m_inputBoxes; }
    QString jsonErrorMessage() const { return m_jsonErrorMessage;}
    int progressValue() const { return m_progressValue; }
    void setProgressValue(int value);

signals:
    void palletInfoUpdated(const QString &info);
    void isFullScreenViewOpenChanged();
    void jsonErrorMessageChanged();
    void isJsonLoadedChanged();
    void simulationStarted();
    void boxInfoUpdated(const QString &boxInfo);
    void boxInfoCleared();
    void isRequestInProgressChanged();
    void serverResponseChanged();
    void progressValueChanged();
    void resultStatsReceived(const QString &result);

private slots:
    void onFullScreen3DWindowClosed();

private:
    NetworkHelper m_networkHelper;
    QJsonObject m_serverResponse;
    bool m_isRequestInProgress = false;

    std::unique_ptr<ThreeDSpaceView> m_3dView;
    QPointer<QQmlContext> m_context;
    QPointer<FullScreen3DWindow> m_secondWindow;
    QJsonArray palletArray;
    bool m_isFullScreenViewOpen = false;
    QJsonArray m_inputBoxes;
    QList<QString> m_invalidBoxes;
    QString m_rawJson;
    QString m_jsonErrorMessage;
    bool m_isJsonLoaded = false;
    bool m_hasSimulationStarted = false;
    int m_progressValue = 0;

    void loadPalletsJson();
};


#endif // __MAINWINDOW_H__