#ifndef __BOXDATA_H_
#define __BOXDATA_H_

#include <QMetaType>
#include <QVector3D>

class BoxData {
    Q_GADGET
    Q_PROPERTY(QVector3D dimensions MEMBER m_dimensions)
    Q_PROPERTY(QVector3D position MEMBER m_position)
    Q_PROPERTY(QVector3D rotation MEMBER m_rotation)
    Q_PROPERTY(QVector3D scaleFactor MEMBER m_scaleFactor)

public:
    QVector3D m_dimensions;
    QVector3D m_position;
    QVector3D m_rotation;
    QVector3D m_scaleFactor;
};

Q_DECLARE_METATYPE(BoxData)

#endif // __BOXDATA_H_
