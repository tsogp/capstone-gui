#include "boxdata.h"

BoxData::BoxData(QVector3D dimensions, QVector3D position, QVector3D rotation, QVector3D scaleFactor)
    : m_dimensions(dimensions), m_position(position), m_rotation(rotation), m_scaleFactor(scaleFactor) {
}