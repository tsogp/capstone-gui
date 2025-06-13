#include "fullscreen3dwindow.h"
#include <QQmlComponent>

#define FULLSCREEN3DWINDOW_URL "qrc:/FullScreen3DView/qml/FullScreen3DWindow.qml"
#define DEBUG_PREFIX "[FullScreen3DWindow]: "

FullScreen3DWindow::FullScreen3DWindow(QQmlEngine* engine, QObject* parent)
    : QObject(parent), m_engine(engine) {}

void FullScreen3DWindow::show(const QString &data) {
    if (m_window && m_window->isVisible()) {
        m_window->raise();
        return;
    }

    QQmlComponent component(m_engine, QUrl(FULLSCREEN3DWINDOW_URL));
    QObject *object = component.create();

    if (!object) {
        qWarning() << DEBUG_PREFIX << "Failed to load " << FULLSCREEN3DWINDOW_URL;
        return;
    }

    m_window = qobject_cast<QQuickWindow*>(object);
    if (!m_window) {
        qWarning() << DEBUG_PREFIX << FULLSCREEN3DWINDOW_URL << " is not a window";
        delete object;
        return;
    }

    m_window->setProperty("receivedText", data);
    connect(m_window, &QQuickWindow::closing, this, &FullScreen3DWindow::onWindowClosed);
    m_window->show();
}

void FullScreen3DWindow::onWindowClosed() {
    emit closed();
    m_window.clear();
}
