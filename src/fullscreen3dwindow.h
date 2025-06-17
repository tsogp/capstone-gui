#ifndef __FULLSCREEN3DWINDOW_H__
#define __FULLSCREEN3DWINDOW_H__

#include <QObject>
#include <QPointer>
#include <QProperty>
#include <QQmlApplicationEngine>
#include <QQuickWindow>

class FullScreen3DWindow : public QObject {
    Q_OBJECT

    Q_PROPERTY(float zoomLevel READ zoomLevel WRITE setZoomLevel NOTIFY zoomLevelChanged FINAL)
    Q_PROPERTY(float viewSliderFirst READ viewSliderFirst WRITE setViewSliderFirst NOTIFY viewSliderFirstChanged FINAL)
    Q_PROPERTY(
        float viewSliderSecond READ viewSliderSecond WRITE setViewSliderSecond NOTIFY viewSliderSecondChanged FINAL)
    Q_PROPERTY(bool isAutoMode READ isAutoMode WRITE setIsAutoMode NOTIFY isAutoModeChanged FINAL)

public:
    FullScreen3DWindow(QQmlEngine *engine, QObject *parent = nullptr);
    void show(const QString &data);

    float zoomLevel() const {
        return m_zoomLevel;
    }
    void setZoomLevel(float value);

    float viewSliderFirst() const {
        return m_viewSliderFirst;
    }
    void setViewSliderFirst(float value);

    float viewSliderSecond() const {
        return m_viewSliderSecond;
    }
    void setViewSliderSecond(float value);

    bool isAutoMode() const {
        return m_isAutoMode;
    }
    void setIsAutoMode(bool value);

signals:
    void closed();
    void finished(const QString &result);

    void zoomLevelChanged();
    void viewSliderFirstChanged();
    void viewSliderSecondChanged();
    void isAutoModeChanged();

private:
    QPointer<QQuickWindow> m_window;
    QQmlEngine *m_engine;

    float m_zoomLevel = 1;
    float m_viewSliderFirst = 0;
    float m_viewSliderSecond = 100;
    bool m_isAutoMode = false;

    void writeSettings();
    void readSettings();

private slots:
    void onWindowClosed();
};

#endif // __FULLSCREEN3DWINDOW_H__