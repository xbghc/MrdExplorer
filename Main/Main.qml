import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 1200
    height: 800

    RowLayout {
        anchors.fill: parent

        Rectangle {
            id: controlPanel
            Layout.fillHeight: true
            Layout.preferredWidth: 300

            FileBrowser {
                id: fileBrowser
                width: controlPanel.width
                height: 260
            }

        }

        Rectangle {
            id: screen

            Layout.fillWidth: true
            Layout.fillHeight: true

            MrdImageViewer {
                id: imageViewer

                anchors.fill: parent
                imageSize: 128
            }
        }
    }

    Connections {
        target: fileBrowser
        function onItemSelectedSignal(newPath) {
            imageViewer.setFolder(newPath);
        }
    }
}
