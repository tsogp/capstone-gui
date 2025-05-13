// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.5
import CapstoneMainscreen
import QtQuick.Layouts

Window {
    id: root
    visible: true
    width: 1920
    height: 1080
    title: qsTr("Qt Design Studio Loader Example")

    Loader {
        id: screenLoader
        anchors.fill: parent
        source: "Mainscreen.ui.qml"

        onLoaded: {
            console.log("Mainscreen loaded successfully.");

            if (item) {
               const browseButton = item.objectName;

               if (browseButton) {
                   console.log("Button found!");
                   browseButton.onClicked.connect(() => {
                       item.state = "State1";
                   });
               } else {
                   console.error("btBrowseFiles not found in loaded item");
               }
           }
        }

        onStatusChanged: {
            if (status === Loader.Error) {
                console.error("Failed to load Mainscreen:", screenLoader.source);
            }
        }
    }
}

