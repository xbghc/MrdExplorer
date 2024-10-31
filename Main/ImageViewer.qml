/*
    ImageViewer需要两个输入：
    1. imageSize：整数，控制图片的大小
    2. sourceMap：二维的字符串数组，每个元素是一个图片的路径
*/

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

ScrollView {
    id: root
    required property int imageSize
    property alias sourceMap: imageGrid.model
    clip: true

    Column {
        id: column
        spacing: 1

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
        spacing: 1
        
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
