#include "3d.h"
#include <QQmlContext>

ThreeDSpaceView::ThreeDSpaceView(QQmlEngine *engine) {
    if (engine && engine->rootContext()) {
        engine->rootContext()->setContextProperty("threeDSpaceView", this);
    } else {
        qWarning() << "Failed to register context property.";
    }
}

void ThreeDSpaceView::setRootObject(QObject *root) {
    m_root = root;
}

QString ThreeDSpaceView::currentModelSource() const {
    return m_currentModelSource;
}

void ThreeDSpaceView::setCurrentModelSource(const QString &src) {
    if (m_currentModelSource != src) {
        QString path = QString("qrc:/FullScreen3DView/assets/models/%1/%2Pallet.qml").arg(src.toLower(), src);
        m_currentModelSource = path;
        emit currentModelSourceChanged(path);

        qDebug() << "currentModelSource updated to:" << src;
    }
}