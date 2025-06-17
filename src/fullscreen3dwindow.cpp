#include "fullscreen3dwindow.h"
#include <QDebug>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickItem>
#include <QSettings>

#define FULLSCREEN3DWINDOW_URL "qrc:/FullScreen3DView/qml/FullScreen3DWindow.qml"
#define WINDOW_NAME "FullScreen3DWindow"
#define DEBUG_PREFIX "[" WINDOW_NAME "]:"

FullScreen3DWindow::FullScreen3DWindow(QQmlEngine *engine, QObject *parent) : QObject(parent), m_engine(engine) {
}

void FullScreen3DWindow::writeSettings() {
    QSettings settings;
    settings.beginGroup(WINDOW_NAME);
    settings.setValue("zoomLevel", m_zoomLevel);
    settings.setValue("viewSliderFirst", m_viewSliderFirst);
    settings.setValue("viewSliderSecond", m_viewSliderSecond);
    settings.setValue("isAutoMode", m_isAutoMode);
    settings.endGroup();
}

void FullScreen3DWindow::readSettings() {
    QSettings settings;

    settings.beginGroup(WINDOW_NAME);
    m_zoomLevel = settings.value("zoomLevel", 1.0).toFloat();
    m_viewSliderFirst = settings.value("viewSliderFirst", 0.0).toFloat();
    m_viewSliderSecond = settings.value("viewSliderSecond", 100.0).toFloat();
    m_isAutoMode = settings.value("isAutoMode", false).toBool();
    settings.endGroup();
}

void FullScreen3DWindow::setZoomLevel(float value) {
    if (m_zoomLevel != value) {
        m_zoomLevel = value;
        emit zoomLevelChanged();
    }
}

void FullScreen3DWindow::setViewSliderFirst(float value) {
    if (m_viewSliderFirst != value) {
        m_viewSliderFirst = value;
        emit viewSliderFirstChanged();
    }
}

void FullScreen3DWindow::setViewSliderSecond(float value) {
    if (m_viewSliderSecond != value) {
        m_viewSliderSecond = value;
        qDebug() << DEBUG_PREFIX << m_viewSliderSecond << value;
        emit viewSliderSecondChanged();
    }
}

void FullScreen3DWindow::setIsAutoMode(bool value) {
    if (m_isAutoMode != value) {
        m_isAutoMode = value;
        emit isAutoModeChanged();
    }
}


void FullScreen3DWindow::show(const QString &data) {
    if (m_window && m_window->isVisible()) {
        m_window->raise();
        return;
    }

    QQmlContext *context = new QQmlContext(m_engine->rootContext());
    context->setContextProperty("settingsBridge", this);

    readSettings();

    QQmlComponent component(m_engine, QUrl(FULLSCREEN3DWINDOW_URL));
    QObject *object = component.create(context);

    if (!object) {
        qWarning() << DEBUG_PREFIX << "Failed to load " << FULLSCREEN3DWINDOW_URL << ":" << component.errors();
        return;
    }

    m_window = qobject_cast<QQuickWindow *>(object);
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
    writeSettings();
    emit closed();
    m_window.clear();
}
