#include "networkhelper.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDebug>
#include <QTimer>

NetworkHelper::NetworkHelper(QObject *parent)
    : QObject(parent) {}

void NetworkHelper::sendPostRequest(const QString &url, const QJsonObject &payload) {
    QNetworkRequest request((QUrl(url)));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonDocument doc(payload);
    QByteArray jsonData = doc.toJson(QJsonDocument::Compact);

    QNetworkReply *reply = m_manager.post(request, jsonData);

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
                if (jsonResponse.object().contains("job_id")) {
                    QString jobId = jsonResponse.object()["job_id"].toString();
                    m_jobs.push(jobId);
                    m_currentJobId = m_jobs.top();
                    emit jobStarted(m_currentJobId);
                }
            }
        }
        reply->deleteLater();
    });
}

void NetworkHelper::pollProgress(const QString &urlBase, int intervalMs) {
    if (m_currentJobId.isEmpty()) {
        emit requestError("No active job to poll");
        return;
    }

    if (!m_progressTimer) {
        m_progressTimer = new QTimer(this);
        connect(m_progressTimer, &QTimer::timeout, this, [this, urlBase]() {
            QString url = QString("%1/progress/%2").arg(urlBase, m_currentJobId);
            QNetworkRequest request((QUrl(url)));
            QNetworkReply *reply = m_manager.get(request);

            connect(reply, &QNetworkReply::finished, this, [this, reply]() {
                if (reply->error() != QNetworkReply::NoError) {
                    emit requestError(reply->errorString());
                } else {
                    QByteArray responseData = reply->readAll();
                    QJsonParseError parseError;
                    QJsonDocument jsonResponse = QJsonDocument::fromJson(responseData, &parseError);

                    if (parseError.error != QJsonParseError::NoError || !jsonResponse.isObject()) {
                        emit requestError("Invalid JSON in progress response");
                    } else {
                        QJsonObject obj = jsonResponse.object();
                        int progress = obj["progress"].toInt();
                        QString status = obj["status"].toString();

                        emit progressUpdated(progress, status);

                        if (status == "done" || status == "error") {
                            m_progressTimer->stop();
                            if (status == "done") {
                                emit jobFinished(m_currentJobId);
                            } else {
                                emit requestError("Job failed");
                            }
                        }
                    }
                }
                reply->deleteLater();
            });
        });
    }

    m_progressTimer->start(intervalMs);
}

void NetworkHelper::fetchResult(const QString &urlBase) {
    if (m_currentJobId.isEmpty()) {
        emit requestError("No active job to fetch result");
        return;
    }

    QString url = QString("%1/result/%2").arg(urlBase, m_currentJobId);
    QNetworkRequest request((QUrl(url)));
    QNetworkReply *reply = m_manager.get(request);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() != QNetworkReply::NoError) {
            emit requestError(reply->errorString());
        } else {
            QByteArray responseData = reply->readAll();
            QJsonParseError parseError;
            QJsonDocument jsonResponse = QJsonDocument::fromJson(responseData, &parseError);

            if (parseError.error != QJsonParseError::NoError || !jsonResponse.isObject()) {
                emit requestError("Invalid JSON in result response");
            } else {
                emit resultReceived(jsonResponse.object());
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
