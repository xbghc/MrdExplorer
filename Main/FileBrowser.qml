pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import Qt.labs.folderlistmodel 2.8

Rectangle {
    id: root

    property alias path: fileModel.folder
    signal folderChangedSignal(string folderPath)
    signal itemSelectedSignal(string itemPath)

    // dispaly mode有2种模式
    // 1. FILE: 文件模式
    // 2. FOLDER: 文件夹模式
    signal displayModeChangedSignal(string mode)

    property string displayMode: "FOLDER"

    color: "lightgray"

    function openFolder(folderPath) {
        fileModel.folder = folderPath;
    }

    RowLayout {
        id: header

        width: root.width
        height: 50

        RadioButton {
            id: radio1

            text: "按文件"
            checked: root.displayMode === "FILE"
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 10

            onClicked: {
                root.displayMode = "FILE";
                root.displayModeChangedSignal("FILE");
            }
        }

        RadioButton {
            id: radio2

            text: "按文件夹"
            checked: root.displayMode === "FOLDER"
            Layout.alignment: Qt.AlignVCenter

            onClicked: {
                root.displayMode = "FOLDER";
                root.displayModeChangedSignal("FOLDER");
            }
        }

        Button {
            text: "选择目录"
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            onClicked: {
                folderDialog.open();
            }

            FolderDialog {
                id: folderDialog
                title: "选择文件夹"

                onAccepted: {
                    root.path = currentFolder;
                    root.openFolder(currentFolder);
                    root.folderChangedSignal(currentFolder);
                }
            }
        }
    } // RowLayout header

    ListView {
        id: listView

        width: root.width
        height: root.height - header.height
        anchors.top: header.bottom

        model: FolderListModel {
            id: fileModel

            folder: "file:///C:/Projects/MRI-ANC/data/1"
            showDirs: root.displayMode === "FOLDER"
            showFiles: root.displayMode === "FILE"
            nameFilters: root.displayMode === "FILE" ? ["*.MRD", "*.mrd"] : []
        }
        delegate: Rectangle {
            id: delegate
            required property string index  // 显式声明必需的属性
            required property string fileName  // 显式声明必需的属性
            width: listView.width
            height: 50

            color: ListView.isCurrentItem ? "lightblue" : "white"

            Text {
                text: delegate.fileName  // 使用声明的属性
                anchors {
                    left: parent.left
                    leftMargin: 10
                    verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    listView.currentIndex = delegate.index;
                    root.itemSelectedSignal(fileModel.folder + "/" + delegate.fileName);
                }
            }
        }
    }
}
