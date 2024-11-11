/*
    MrdImageViewer使用ImageViewer显示图片，
    它根据外部传入的参数来调整对ImageViewer的调用。
    所需的参数包括
    1. path：字符串，图片文件或其所在文件夹的目录
    2. displayMode：字符串，显示模式可以是"ALL"、"SINGLE_CHANNEL"或"SINGLE_SLICE"
    注意，path并非直接传递给MrdImageViewer，而是通过setFolder方法传递给它。

    当外部调用setFolder，MrdImageViewer会经历以下步骤：
    1. 让imageProvider重新加载图片
    2. imageProvider返回通道列表channels和切片数sliceCount
    3. MrdImageViewer生成sourceMap
    之所以要让imageProvider返回通道列表后才生成sourceMap，
    是因为当displayMode是ALL的时候，需要知道通道和切片的数量才能列举所有的图片

    由于channels可能不连续，所以设置channel的索引类型为字符串，用字典索引。
    而slices是连续的，所以设置slice的类型为整数，用数组索引。
    因为ImageViewer使用Repeater来生成图片，不能接受字典，所以传给它的是字典中keys的数组。
*/

import QtQuick
import main.backend

Rectangle {
    id: root

    property alias model: imageViewer.sourceMap
    property int imageSize: 128

    ImageViewer {
        id: imageViewer
        anchors.fill: parent
        imageSize: root.imageSize
    }

    Image {
        id: triggerImage
        visible: false
    }

    function setSource(url) {
        model = Backend.getImagesSources(url); // qmllint disable unqualified
    }
}
