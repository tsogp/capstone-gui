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

    property real zoomMin: 0.5
    property real zoomMax: 3.0
    property real zoomLevel: 1.0
    property vector2d rotationDelta: Qt.vector2d(0, 0)
    property vector3d palletRotation: Qt.vector3d(15, 70, 30)
    property string currentModelSource: "qrc:/FullScreen3DView/assets/models/eur/EuroPallet.qml"
    property string boxSource: "qrc:/FullScreen3DView/assets/models/box/CartonBox.qml"
    property vector3d palletData

    property real slideLeft: 0.0
    property real slideRight: 0.0

    property var spawnedBoxes: []
    property bool fromFullScreen: false

    property bool viewSlicingEnabled: false

    onSlideLeftChanged: {
        moveSlicePlane(true);
    }

    onSlideRightChanged: {
        moveSlicePlane(false);
    }

    onViewSlicingEnabledChanged: {
        // Can only be changed when the fullscreen is opened
        if (fromFullScreen) {
            if (!viewSlicingEnabled) {
                for (let i = 0; i < spawnedBoxes.length; ++i) {
                    spawnedBoxes[i].visible = true;
                }
            } else {
                moveSlicePlane(true);
                moveSlicePlane(false);
            }
        }
    }

    Component.onCompleted: {
        rotationDelta = threeDSpaceView.rotationDelta;
        zoomLevel = threeDSpaceView.zoomLevel;
        palletData = threeDSpaceView.palletData;

        applyRotationToAll();
        applyZoomToAll();

        let boxes = threeDSpaceView.getBoxes();
        for (let i = 0; i < boxes.length; ++i) {
            spawnBoxInQML(boxes[i].position, boxes[i].scaleFactor, boxes[i].dimensions);

            if (!fromFullScreen || !viewSlicingEnabled) {
                boxes[i].visible = true;
            }
        }

        if (fromFullScreen) {
            moveSlicePlane(true);
            moveSlicePlane(false);
        }
    }

    Component.onDestruction: {
        // TODO BUG: currently if the component is opened from fullscreen,
        // is it not destroyed until the whole program is closed
        console.log("destroyed");
    }

    Connections {
        target: threeDSpaceView

        function onRotationDeltaChanged() {
            rotationDelta = threeDSpaceView.rotationDelta;
        }

        function onZoomLevelChanged() {
            zoomLevel = threeDSpaceView.zoomLevel;
        }

        function onPalletDataChanged() {
            palletData = threeDSpaceView.palletData;
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

        onWheel: wheel => modifyZoomLevel(wheel.angleDelta.y / (Math.abs(wheel.angleDelta.y) * 10), wheel.inverted)
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

            Node {
                id: clipPlanes

                // Left plane
                Model {
                    id: leftPlane
                    source: "#Rectangle"
                    scale: Qt.vector3d(2, 20, 2)  // thin X-axis oriented plane
                    position: Qt.vector3d(0, 0, -(palletData.z / 2))
                    visible: viewSlicingEnabled && fromFullScreen
                    materials: PrincipledMaterial {
                        baseColor: "#aaffff" // light cyan for visibility
                        opacity: 0.3
                        roughness: 0.1
                        metalness: 0.0
                        cullMode: Material.NoCulling
                    }
                }

                // Right plane
                Model {
                    id: rightPlane
                    source: "#Rectangle"
                    scale: Qt.vector3d(2, 20, 2)
                    position: Qt.vector3d(0, 0, palletData.z / 2)
                    visible: viewSlicingEnabled && fromFullScreen
                    materials: PrincipledMaterial {
                        baseColor: "#aaffff"
                        opacity: 0.3
                        roughness: 0.1
                        metalness: 0.0
                        cullMode: Material.NoCulling
                    }
                }
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
            spawnBoxInQML(box.position, box.scaleFactor, box.dimensions);
        }
    }

    function moveSlicePlane(left) {
        const zMin = -(palletData.z / 2);
        const zMax = (palletData.z / 2);

        if (left) {
            leftPlane.position.z = zMin + (zMax - zMin) * (slideLeft / 100);
        } else {
            rightPlane.position.z = zMax - (zMax - zMin) * (1 - slideRight / 100);
        }
        checkCollisions();
    }

    function applyRotationToAll() {
        rotationRoot.eulerRotation.y = -rotationDelta.x;
        threeDSpaceView.rotationDelta = rotationDelta;
    }

    function spawnBoxInQML(position, scale, dimensions) {
        // TODO: remove, for debugging only
        console.log("Spawning box at", position, "with scale", scale, "with dimensions", dimensions);
        var component = Qt.createComponent(boxSource);
        if (component.status === Component.Ready) {
            var box = component.createObject(shapeSpawner, {
                "position": position,
                "scale": scale,
                "dimensions": dimensions,
                "animStartY": 150,
                "animEndY": position.y
            });

            if (box) {
                spawnedBoxes.push(box);
            } else {
                console.error("Failed to create box");
            }
        } else {
            console.error("Box component error:", component.errorString());
        }
    }

    function checkCollisions() {
        function checkBoxPlaneCollision(planeZ, box, positiveDirection) {
            const halfDepth = box.dimensions.z * box.scale.z * 0.5;

            // Checking if left plane has touched the left side of the box
            if (positiveDirection) {
                const boxMinZ = box.position.z - halfDepth;
                return planeZ >= boxMinZ;
            }

            // Checking if right plane has touched the right side of the box
            const boxMaxZ = box.position.z + halfDepth;
            return planeZ <= boxMaxZ;
        }

        for (let i = 0; i < spawnedBoxes.length; ++i) {
            let box = spawnedBoxes[i];

            let leftHit = checkBoxPlaneCollision(leftPlane.position.z, box, true);
            let rightHit = checkBoxPlaneCollision(rightPlane.position.z, box, false);

            if (leftHit || rightHit) {
                box.visible = false;
            } else {
                box.visible = true;
            }
        }
    }

    function modifyZoomLevel(incValue, isInverted) {
        let delta = isInverted ? -incValue : incValue;
        if (delta >= 0) {
            zoomLevel = Math.min(zoomLevel + delta, zoomMax);
        } else {
            zoomLevel = Math.max(zoomLevel + delta, zoomMin);
        }
        applyZoomToAll();
    }

    function applyZoomToAll() {
        threeDSpaceView.zoomLevel = zoomLevel;
        camera.position.z = cameraPosition.z / zoomLevel;
    }
}
