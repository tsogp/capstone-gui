#ifndef __BOXDATA_H_
#define __BOXDATA_H_

#include <QMetaType>
#include <QVector3D>

class BoxData {
    Q_GADGET
    Q_PROPERTY(int id MEMBER m_id)
    Q_PROPERTY(double weight MEMBER m_weight)
    Q_PROPERTY(int maxLoad MEMBER m_maxLoad)
    Q_PROPERTY(QVector3D dimensions MEMBER m_dimensions)
    Q_PROPERTY(QVector3D position MEMBER m_position)
    Q_PROPERTY(QVector3D rotation MEMBER m_rotation)
    Q_PROPERTY(QVector3D scaleFactor MEMBER m_scaleFactor)

public:
    BoxData() = default;
    BoxData(QVector3D dimensions, QVector3D position, QVector3D m_rotation, QVector3D scaleFactor);
    BoxData(int id, int width, int length, int height, double weight, int maxLoad);

    int m_id;
    double m_weight;
    int m_maxLoad;

    QVector3D m_dimensions;
    QVector3D m_position;
    QVector3D m_rotation;
    QVector3D m_scaleFactor;
};

Q_DECLARE_METATYPE(BoxData)

#endif // __BOXDATA_H_
