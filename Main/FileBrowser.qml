pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import QtCore
import main.backend

Rectangle {
    id: root

    signal fileChanged(string url)

    property bool mergeChannels: true
    property alias hideSingle: hideSingleCheckBox.checked
    property string folder: ""

    function openFolder(folderPath) {
        folder = folderPath;
        listView.model = Backend.listdir(folderPath, mergeChannels, hideSingle);  // qmllint disable unqualified
        textField.text = folderPath;
        Backend.saveLastFolder(folderPath);  // qmllint disable unqualified
    }

    function openParentFolder() {
        var newPath = folder.substring(0, folder.lastIndexOf('/'));
        openFolder(newPath);
    }

    Component.onCompleted: {
        var lastFolder = Backend.getLastFolder();  // qmllint disable unqualified
        if (lastFolder && lastFolder.length > 0) {
            openFolder(lastFolder);
            return;
        }

        var homePath = StandardPaths.writableLocation(StandardPaths.HomeLocation).toString()
        // Windows: file:///C:/Users/xxx -> C:/Users/xxx
        // Linux/Mac: file:///home/xxx -> /home/xxx
        if (homePath.startsWith("file:///") && homePath.charAt(9) === ':') {
            homePath = homePath.replace("file:///", "")
        } else {
            homePath = homePath.replace("file://", "")
        }
        openFolder(homePath)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        anchors.topMargin: 10

        CheckBox {
            id: hideSingleCheckBox

            checked: true
            text: qsTr("Hide Single-Channel Scan")

            Layout.leftMargin: 5
        }

        RowLayout {
            id: header
            width: root.width
            height: 50
            Layout.leftMargin: 5

            Button {
                text: qsTr("<")

                onClicked: {
                    root.openParentFolder();
                }
            }

            TextField {
                id: textField

                onAccepted: {}

                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Change Folder")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                onClicked: {
                    folderDialog.open();
                }

                FolderDialog {
                    id: folderDialog
                    title: "Select Folder"

                    onAccepted: {
                        let p = currentFolder.toString().replace("file:///", "");
                        root.openFolder(p);
                    }
                }
            }
        } // RowLayout header

        ListView {
            id: listView

            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            ScrollBar.vertical: ScrollBar {
                id: vbar
                active: listView.moving || pressed
                policy: ScrollBar.AsNeeded
            }

            delegate: Rectangle {
                id: delegate

                required property int index
                required property string filename
                required property bool isDir
                required property string url

                width: ListView.view.width
                height: 50
                color: ListView.isCurrentItem ? "lightblue" : "lightgray"

                Text {
                    text: delegate.filename

                    anchors {
                        left: parent.left
                        leftMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    color: delegate.isDir ? "brown" : "black"
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: function(mouse) {
                        if (mouse.button === Qt.RightButton) {
                            contextMenu.popup();
                        } else {
                            if (delegate.isDir) {
                                root.openFolder(delegate.url);
                            } else {
                                root.fileChanged(delegate.url);
                                listView.currentIndex = delegate.index;
                            }
                        }
                    }

                    Menu {
                        id: contextMenu
                        MenuItem {
                            text: qsTr("Copy Path")
                            onTriggered: {
                                Backend.copyToClipboard(delegate.url);  // qmllint disable unqualified
                            }
                        }
                    }
                }
            }
        }
    }
}
