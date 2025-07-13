#include "boxdata.h"

BoxData::BoxData(QVector3D dimensions, QVector3D position, QVector3D rotation, QVector3D scaleFactor)
    : m_dimensions(dimensions), m_position(position), m_rotation(rotation), m_scaleFactor(scaleFactor) {
}

BoxData::BoxData(int id, int width, int length, int height, double weight, int maxLoad)
    : m_id(id), m_weight(weight), m_maxLoad(maxLoad) {
    m_dimensions = QVector3D(width, length, height);
    m_position = QVector3D(0, 0, 0);    // Default position
    m_scaleFactor = QVector3D(1, 1, 1); // Default scale factor
}