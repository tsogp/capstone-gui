#include "fullscreen3dwindow.h"
#include <QDebug>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickItem>
#include <QSettings>

#define FULLSCREEN3DWINDOW_URL "qrc:/FullScreen3DView/qml/FullScreen3DWindow.qml"
#define WINDOW_NAME "FullScreen3DWindow"
#define DEBUG_PREFIX "[" WINDOW_NAME "]:"

FullScreen3DWindow::FullScreen3DWindow(QQmlEngine *engine, QQmlContext *contextPtr, QObject *parent)
    : m_engine(engine), m_parentContext(contextPtr), QObject(parent) {
}

void FullScreen3DWindow::writeSettings() {
    QSettings settings;
    settings.beginGroup(WINDOW_NAME);
    settings.setValue("viewSliderFirst", m_viewSliderFirst);
    settings.setValue("viewSliderSecond", m_viewSliderSecond);
    settings.setValue("viewSlicingEnabled", m_viewSlicingEnabled);
    settings.endGroup();
}

void FullScreen3DWindow::readSettings() {
    QSettings settings;

    settings.beginGroup(WINDOW_NAME);
    m_viewSliderFirst = settings.value("viewSliderFirst", 0.0).toFloat();
    m_viewSliderSecond = settings.value("viewSliderSecond", 100.0).toFloat();
    m_viewSlicingEnabled = settings.value("viewSlicingEnabled", false).toBool();
    settings.endGroup();
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
        emit viewSliderSecondChanged();
    }
}

void FullScreen3DWindow::setViewSlicingEnabled(bool value) {
    if (m_viewSlicingEnabled != value) {
        m_viewSlicingEnabled = value;
        emit viewSlicingEnabledChanged();
    }
}

void FullScreen3DWindow::show(const QString &data) {
    if (m_window && m_window->isVisible()) {
        m_window->raise();
        return;
    }

    m_parentContext->setContextProperty("settingsBridge", this);

    readSettings();

    QQmlComponent component(m_engine.data(), QUrl(FULLSCREEN3DWINDOW_URL));
    QObject *object = component.create(m_parentContext.data());
    object->setParent(this);

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
}
