#include "3d.h"

ThreeDSpaceView::ThreeDSpaceView() {
}

void ThreeDSpaceView::setRootObject(QObject *root) {
    m_root = root;
}

QString ThreeDSpaceView::currentModelSource() const {
    if (!m_root) {
        return QString();
    }

    return m_root->property("currentModelSource").toString();
}

void ThreeDSpaceView::setCurrentModelSource(const QString &src) {
    if (m_root) {
        m_root->setProperty("currentModelSource", src);
    }
}