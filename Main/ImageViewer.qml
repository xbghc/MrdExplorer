pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Flickable {
    id: root

    function setSourceMap(sm) {
        imageGrid.model = sm;
    }
    contentWidth: column.width
    contentHeight: column.height
    clip: true

    required property int imageSize

    ScrollBar.vertical: ScrollBar {
        id: vbar
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    ScrollBar.horizontal: ScrollBar {
        id: hbar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Column {
        id: column
        rightPadding: vbar.width
        bottomPadding: hbar.height

        Repeater {
            id: imageGrid

            model: [[]]
            delegate: ImageLine {
                required property var modelData

                images: modelData
            }
        }
    }

    component ImageLine: Row {
        id: imageLine
        required property var images  // list<string>
        height: root.imageSize
        Repeater {
            model: imageLine.images
            delegate: Item {
                id: imageDelegate

                required property string modelData
                width: root.imageSize
                height: root.imageSize
                Image {
                    anchors.fill: parent
                    source: imageDelegate.modelData
                }
            }
        }
    }
}
