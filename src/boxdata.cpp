#include "boxdata.h"
#include <qvectornd.h>

static constexpr QVector3D boxUnitSize = QVector3D(38.11, 38.11, 38.11);

BoxData::BoxData(int id,
                 double weight,
                 int maxLoad,
                 QVector3D position,
                 QVector3D rotation,
                 QVector3D scaleFactor,
                 QVector3D dimensions)
    : m_id(id), m_weight(weight), m_maxLoad(maxLoad), m_position(position), m_rotation(rotation),
      m_scaleFactor(scaleFactor), m_dimensions(dimensions) {
}

QVector3D BoxData::dimensions() const {
    return m_dimensions;
}

QVector3D BoxData::boxSize() const {
    return boxUnitSize;
}