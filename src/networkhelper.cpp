#include "networkhelper.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDebug>

NetworkHelper::NetworkHelper(QObject *parent)
    : QObject(parent) {}

void NetworkHelper::sendPutRequest(const QString &url, const QJsonObject &payload) {
    QNetworkRequest request((QUrl(url)));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonDocument doc(payload);
    QByteArray jsonData = doc.toJson(QJsonDocument::Compact);

    QNetworkReply *reply = m_manager.put(request, jsonData);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() != QNetworkReply::NoError) {
            emit requestError(reply->errorString());
        } else {
            QByteArray responseData = reply->readAll();
            QJsonParseError parseError;
            QJsonDocument jsonResponse = QJsonDocument::fromJson(responseData, &parseError);

            if (parseError.error != QJsonParseError::NoError || !jsonResponse.isObject()) {
                emit requestError("Invalid JSON in server response");
            } else {
                emit requestFinished(jsonResponse.object());
            }
        }
        reply->deleteLater();
    });
}

void NetworkHelper::checkServerConnection(const QString &url) {
    QNetworkRequest request((QUrl(url)));
    QNetworkReply *reply = m_manager.head(request);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        bool success = (reply->error() == QNetworkReply::NoError);
        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        emit connectionCheckFinished(success, statusCode);
        reply->deleteLater();
    });
}
