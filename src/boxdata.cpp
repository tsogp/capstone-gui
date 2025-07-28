#include "boxdata.h"
#include <qvectornd.h>

static constexpr QVector3D boxSize = QVector3D(38.11, 38.11, 38.11);

BoxData::BoxData(int id, double weight, int maxLoad, QVector3D position, QVector3D rotation, QVector3D scaleFactor)
    : m_id(id), m_weight(weight), m_maxLoad(maxLoad), m_position(position), m_rotation(rotation),
      m_scaleFactor(scaleFactor), m_dimensions(boxSize) {
}

QVector3D BoxData::dimensions() const {
    return boxSize;
}