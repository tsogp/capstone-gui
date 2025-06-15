#include <QTest>
#include <QDirIterator>
#include <qtestcase.h>

class TestAssetsLoad: public QObject {
    Q_OBJECT
private slots:
    void testAssetsLoadOk();
};

void TestAssetsLoad::testAssetsLoadOk() {
    QDirIterator it(":/FullScreen3DView", QDirIterator::Subdirectories);
    QVERIFY2(it.hasNext(), "Resource directory is empty, missing or not loaded properly");
}

QTEST_MAIN(TestAssetsLoad);
#include "testassetsload.moc"