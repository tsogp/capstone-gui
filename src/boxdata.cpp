#include "boxdata.h"
#include <qvectornd.h>

constexpr QVector3D boxSize = QVector3D(38.11, 38.11, 38.11);

BoxData::BoxData(QVector3D position, QVector3D rotation, QVector3D scaleFactor)
    : m_position(position), m_rotation(rotation), m_scaleFactor(scaleFactor) {
}

QVector3D BoxData::dimensions() const {
    return boxSize;
}