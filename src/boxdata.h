#ifndef __BOXDATA_H_
#define __BOXDATA_H_

#include <QMetaType>
#include <QVector3D>
#include <qvectornd.h>

class BoxData {
    Q_GADGET
    Q_PROPERTY(QVector3D dimensions READ dimensions CONSTANT)
    Q_PROPERTY(QVector3D position MEMBER m_position)
    Q_PROPERTY(QVector3D rotation MEMBER m_rotation)
    Q_PROPERTY(QVector3D scaleFactor MEMBER m_scaleFactor)

public:
    BoxData() = default;
    BoxData(QVector3D position, QVector3D rotation, QVector3D scaleFactor);

    QVector3D m_position;
    QVector3D m_rotation;
    QVector3D m_scaleFactor;

    QVector3D dimensions() const;
};

Q_DECLARE_METATYPE(BoxData)

#endif // __BOXDATA_H_
