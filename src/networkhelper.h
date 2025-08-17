#ifndef __FULLSCREEN3DVIEW_NETWORKHELPER_H__
#define __FULLSCREEN3DVIEW_NETWORKHELPER_H__

#include <QObject>
#include <QNetworkAccessManager>
#include <QJsonObject>
#include <QJsonDocument>

class NetworkHelper : public QObject {
    Q_OBJECT
public:
    explicit NetworkHelper(QObject *parent = nullptr);

    Q_INVOKABLE void sendPutRequest(const QString &url, const QJsonObject &payload);
    Q_INVOKABLE void checkServerConnection(const QString &url);

signals:
    void requestFinished(const QJsonObject &response);
    void requestError(const QString &error);

    void connectionCheckFinished(bool isConnected, int statusCode);

private:
    QNetworkAccessManager m_manager;
};

#endif // __FULLSCREEN3DVIEW_NETWORKHELPER_H__
