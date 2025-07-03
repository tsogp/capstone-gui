// ThreeDView.qml
import QtQuick
import QtQuick.Controls
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

Item {
    id: root

    readonly property vector3d cameraPosition: Qt.vector3d(0, 10, 300)
    readonly property vector3d lightRotation: Qt.vector3d(-25.34759, -2.67751, -19.212)

    property alias view: view3D

    property vector2d rotationDelta: Qt.vector2d(0, 0)
    property vector3d palletRotation: Qt.vector3d(15, 70, 30)
    property string currentModelSource: "qrc:/FullScreen3DView/assets/models/eur/EuroPallet.qml"
    property string boxSource: "qrc:/FullScreen3DView/assets/models/box/CartonBox.qml"

    Component.onCompleted: {
        rotationDelta.x = -palletRotation.y;

        let boxes = threeDSpaceView.getBoxes();
        for (let i = 0; i < boxes.length; ++i) {
            spawnBoxInQML(boxes[i].position, palletRotation, boxes[i].scaleFactor);
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        drag.target: null

        property real lastX
        property real lastY

        onPressed: {
            lastX = mouseX;
            lastY = mouseY;
        }

        onPositionChanged: {
            const deltaX = (lastX - mouseX) * 0.5;
            const deltaY = (lastY - mouseY) * 0.5;

            rotationDelta.x += deltaX;
            rotationDelta.y += deltaY;

            lastX = mouseX;
            lastY = mouseY;

            applyRotationToAll();
        }
    }

    View3D {
        id: view3D
        anchors.fill: parent

        environment: SceneEnvironment {
            id: sceneEnvironment
            clearColor: "white"
            backgroundMode: SceneEnvironment.Color
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
        }

        PerspectiveCamera {
            id: camera
            position: cameraPosition
            clipNear: 1.0
        }

        DirectionalLight {
            position: Qt.vector3d(0, 430, 900)
            brightness: 1
            eulerRotation.x: lightRotation.x
            eulerRotation.y: lightRotation.y
            eulerRotation.z: lightRotation.z
            ambientColor: Qt.rgba(0.5, 0.5, 0.5, 1.0)
        }

        Node {
            id: rotationRoot
            eulerRotation: palletRotation

            Loader3D {
                id: palletLoader
                objectName: "palletLoader"
                source: threeDSpaceView.currentModelSource
                active: true
                asynchronous: true

                onLoaded: {
                    item.position = Qt.vector3d(0, 5, 0);
                    item.scale = Qt.vector3d(1.5, 1.5, 1.5);
                }
            }

            Node {
                id: shapeSpawner
                position: Qt.vector3d(0, 30, 0)
                objectName: "shapeSpawner"
            }
        }
    }

    // TODO: remove, for debugging only
    Button {
        id: spawnBoxButton
        text: "Spawn Box"
        width: 120
        height: 40
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 16
        }

        onClicked: {
            let box = threeDSpaceView.getNewBox();
            spawnBoxInQML(box.position, box.scaleFactor);
        }
    }

    function applyRotationToAll() {
        rotationRoot.eulerRotation.y = -rotationDelta.x;
    }

    function spawnBoxInQML(position, scale) {
        // TODO: remove, for debugging only
        console.log("Spawning box at", position, "with scale", scale);
        var component = Qt.createComponent(boxSource);
        if (component.status === Component.Ready) {
            var box = component.createObject(shapeSpawner, {
                "position": position,
                "scale": scale
            });
            if (!box) {
                console.error("Failed to create box");
            }
        } else {
            console.error("Box component error:", component.errorString());
        }
    }
}
