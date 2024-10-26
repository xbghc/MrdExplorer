pragma ComponentBehavior: Bound
import QtQuick

Rectangle {
    id: root

    function setSourceMap(sm) {
        imageGrid.model = sm;
    }

    required property int imageSize

    Column {
        anchors.fill: parent

        Repeater {
            id: imageGrid
            // anchors.fill: parent

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
