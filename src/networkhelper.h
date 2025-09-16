#ifndef __FULLSCREEN3DVIEW_NETWORKHELPER_H__
#define __FULLSCREEN3DVIEW_NETWORKHELPER_H__

#include <QObject>
#include <QNetworkAccessManager>
#include <QJsonObject>
#include <QJsonDocument>
#include <qobject.h>
#include <qstack.h>
#include <QTimer>

class NetworkHelper : public QObject {
    Q_OBJECT
public:
    explicit NetworkHelper(QObject *parent = nullptr);

    Q_INVOKABLE void sendPostRequest(const QString &url, const QJsonObject &payload);
    Q_INVOKABLE void checkServerConnection(const QString &url);
    void pollProgress(const QString &urlBase, int intervalMs);
    void fetchResult(const QString &url);
    QString currentJobId() const { return m_currentJobId; }

signals:
    void jobStarted(const QString &jobId);
    void progressUpdated(int progress, const QString &status);
    void jobFinished(const QString &jobId);
    void resultReceived(const QJsonObject &result);
    void requestError(const QString &error);

    void connectionCheckFinished(bool isConnected, int statusCode);

private:
    QNetworkAccessManager m_manager;
    QStack<QString> m_jobs;
    QString m_currentJobId;
    QTimer *m_progressTimer = nullptr;
};

#endif // __FULLSCREEN3DVIEW_NETWORKHELPER_H__
