// ThreeDView.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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

    Connections {
        target: threeDSpaceView

        function onUpdateBoxInfo(boxInfo) {
            mainWindow.updateBoxInfo(boxInfo);
        }

        function onSpawnBoxRequested() {
            let box = threeDSpaceView.getNewBox();
            if (box !== null && box !== undefined) {
                spawnBoxInQML(box.position, box.scaleFactor, box.dimensions, box.id);
            }
        }

        function onDespawnBoxRequested() {
            despawnNewestBox();
        }
    }

    Component.onCompleted: {
        rotationDelta = threeDSpaceView.rotationDelta;
        zoomLevel = threeDSpaceView.zoomLevel;
        palletData = threeDSpaceView.palletData;

        applyRotationToAll();
        applyZoomToAll();

        if (fromFullScreen && viewSlicingEnabled) {
            moveSlicePlane(true);
            moveSlicePlane(false);
        }

        let boxes = threeDSpaceView.getSpawnedBoxes();
        for (let i = 0; i < boxes.length; ++i) {
            spawnBoxInQML(boxes[i].position, boxes[i].scaleFactor, boxes[i].dimensions, boxes[i].id);
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

        onClicked: function (mouse) {
            var result = view3D.pick(mouse.x, mouse.y);

            if (result.objectHit && result.objectHit.objectName === "cartonBoxModel") {
                var pickedModel = result.objectHit;
                var boxNode = pickedModel.parent;

                // Deselect previously selected box
                if (view3D.selectedBox && view3D.selectedBox !== boxNode) {
                    view3D.selectedBox.model.isPicked = false;
                }

                // Mark the new box as selected
                if (pickedModel.isPicked) {
                    pickedModel.isPicked = false;
                    view3D.selectedBox = null;
                    mainWindow.clearBoxInfo();
                } else {
                    pickedModel.isPicked = true;
                    view3D.selectedBox = boxNode;
                    threeDSpaceView.select3DBox(boxNode.boxId);
                }
            }
        }
    }

    View3D {
        id: view3D
        anchors.fill: parent

        property var selectedBox: null

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
                    item.position.x = 0;
                    item.position.z = 0;
                }
            }

            Node {
                id: shapeSpawner
                position: Qt.vector3d(0, 0, 0)
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
    
    Item {
        width: controlLayout.implicitWidth
        height: controlLayout.implicitHeight
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        
        
        ColumnLayout {
            id: controlLayout
            spacing: 10
            visible: mainWindow.hasSimulationStarted

            Switch {
                id: switchAutoMode
                enabled: !isLoading
                Layout.alignment: Qt.AlignHCenter
                text: checked ? "Auto-play ON" : "Auto-play OFF"
                checked: threeDSpaceView.autoMode
                onClicked: {
                    threeDSpaceView.setAutoMode(checked);
                }
            }

            RowLayout {
                id: buttonLayout
                spacing: 10
                enabled: !threeDSpaceView.autoMode

                Button {
                    id: prevStepButton
                    height: 40
                    width: 40
                    enabled: threeDSpaceView.canGoPrevious
                    icon.source: "qrc:/FullScreen3DView/assets/angle-double-left-24.png"
                    display: AbstractButton.IconOnly
                    ToolTip.visible: !buttonLayout.enabled && hovered
                    ToolTip.text: qsTr("Turn off Auto Mode to enable")

                    onClicked: threeDSpaceView.despawnNewestBox()
                }

                Button {
                    id: pauseButton
                    height: 40
                    width: 40
                    icon.source: "qrc:/FullScreen3DView/assets/pause-24.png"
                    display: AbstractButton.IconOnly
                    ToolTip.visible: !buttonLayout.enabled && hovered
                    ToolTip.text: qsTr("Turn off Auto Mode to enable")
                }

                Button {
                    id: nextStepButton
                    height: 40
                    width: 40
                    enabled: threeDSpaceView.canGoNext
                    icon.source: "qrc:/FullScreen3DView/assets/angle-double-right-24.png"
                    display: AbstractButton.IconOnly
                    ToolTip.visible: !buttonLayout.enabled && hovered
                    ToolTip.text: qsTr("Turn off Auto Mode to enable")

                    onClicked: threeDSpaceView.spawnBoxManual()
                }
            }
        }
    }
    

    function moveSlicePlane(left) {
        const zMin = -(palletData.z / 2) - 2.5;
        const zMax = (palletData.z / 2) + 2.5;

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

    function spawnBoxInQML(position, scale, dimensions, id) {
        // TODO: remove, for debugging only
        console.log("Spawning box at", position, "with scale", scale, "with dimensions", dimensions);
        var component = Qt.createComponent(boxSource);
        if (component.status === Component.Ready) {
            var box = component.createObject(shapeSpawner, {
                "position": position,
                "scale": scale,
                "dimensions": dimensions,
                "boxId": id
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

    function despawnNewestBox() {
        if (spawnedBoxes.length > 0) {
            let box = spawnedBoxes.pop();
            box.destroy();
            console.log("Despawning box with id", box.boxId);
        }
    }

    function checkCollisions() {
        function checkBoxPlaneCollision(planeZ, box, positiveDirection) {
            const depth = box.dimensions.z * box.scale.z;

            console.log(depth, box.position, box.dimensions, box.scale, box.position.z - depth, planeZ);

            // Checking if left plane has touched the left side of the box
            if (positiveDirection) {
                const boxMinZ = box.position.z - depth;
                return planeZ >= boxMinZ;
            }

            // Checking if right plane has touched the right side of the box
            const boxMaxZ = box.position.z + depth;
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
