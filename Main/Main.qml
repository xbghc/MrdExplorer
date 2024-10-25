import QtQuick

Rectangle {
    id: root
    width: 1200
    height: 800

    Rectangle {
        id: controlPanel

        width: 300
        height: root.height
        anchors.left: root.left


        FileBrowser {
            id: fileBrowser
            width: controlPanel.width
            height: controlPanel.height
        }
    }

    Rectangle {
        id: screen

        width: root.width - controlPanel.width
        height: root.height
        anchors.right: root.right

        ImageViewer {
            id: imageViewer
            width: screen.width
            height: screen.height
        }
    }

}
