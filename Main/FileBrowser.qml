pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import Qt.labs.platform
import QtCore
import main.backend

Rectangle {
    id: root

    signal fileChanged(string url)

    property bool mergeChannels: true
    property alias hideSingle: hideSingleCheckBox.checked
    property alias showHidden: showHiddenCheckBox.checked
    property string folder: ""

    function openFolder(folderPath) {
        folder = folderPath;
        listView.model = Backend.listdir(folderPath, mergeChannels, hideSingle, showHidden);  // qmllint disable unqualified
        textField.text = folderPath;
        Backend.saveLastFolder(folderPath);  // qmllint disable unqualified
    }

    function refreshFolder() {
        if (folder && folder.length > 0) {
            listView.model = Backend.listdir(folder, mergeChannels, hideSingle, showHidden);  // qmllint disable unqualified
        }
    }

    function openParentFolder() {
        var newPath = folder.substring(0, folder.lastIndexOf('/'));
        openFolder(newPath);
    }

    function selectFile(fileUrl, index) {
        fileChanged(fileUrl);
        listView.currentIndex = index;
        Backend.saveLastFile(fileUrl);  // qmllint disable unqualified
    }

    function restoreLastFile() {
        var lastFile = Backend.getLastFile();  // qmllint disable unqualified
        if (!lastFile || lastFile.length === 0) {
            return;
        }

        // 在当前列表中查找并选中上次的文件
        for (var i = 0; i < listView.count; i++) {
            var item = listView.model[i];
            if (item.url === lastFile) {
                selectFile(lastFile, i);
                return;
            }
        }
    }

    Component.onCompleted: {
        var lastFolder = Backend.getLastFolder();  // qmllint disable unqualified
        if (lastFolder && lastFolder.length > 0) {
            openFolder(lastFolder);
            restoreLastFile();
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

        Controls.CheckBox {
            id: hideSingleCheckBox

            checked: true
            text: qsTr("Hide Single-Channel Scan")

            Layout.leftMargin: 5

            onCheckedChanged: root.refreshFolder()
        }

        RowLayout {
            Layout.leftMargin: 5
            spacing: 10

            Controls.CheckBox {
                id: showHiddenCheckBox

                checked: false
                text: qsTr("Show Hidden Files")

                onCheckedChanged: root.refreshFolder()
            }

            Controls.Button {
                text: qsTr("Clear All Data")

                onClicked: {
                    Backend.clearAllSettings();  // qmllint disable unqualified
                    root.refreshFolder();
                }
            }
        }

        RowLayout {
            id: header
            width: root.width
            height: 50
            Layout.leftMargin: 5

            Controls.Button {
                text: qsTr("<")

                onClicked: {
                    root.openParentFolder();
                }
            }

            Controls.TextField {
                id: textField

                onAccepted: {}

                Layout.fillWidth: true
            }

            Controls.Button {
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
            Controls.ScrollBar.vertical: Controls.ScrollBar {
                id: vbar
                active: listView.moving || pressed
                policy: Controls.ScrollBar.AsNeeded
            }

            delegate: Rectangle {
                id: delegate

                required property int index
                required property string filename
                required property bool isDir
                required property string url
                required property int coilCount
                required property bool isHidden

                width: ListView.view.width
                height: 50
                color: ListView.isCurrentItem ? "lightblue" : "lightgray"
                opacity: delegate.isHidden ? 0.5 : 1.0

                RowLayout {
                    anchors {
                        left: parent.left
                        leftMargin: 10
                        right: parent.right
                        rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: delegate.filename
                        color: delegate.isDir ? "brown" : "black"
                        Layout.fillWidth: true
                    }

                    Text {
                        text: delegate.coilCount > 0 ? "[" + delegate.coilCount + "]" : ""
                        color: "gray"
                        visible: !delegate.isDir && delegate.coilCount > 0
                        Layout.rightMargin: 5
                    }
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
                                root.selectFile(delegate.url, delegate.index);
                            }
                        }
                    }

                    Controls.Menu {
                        id: contextMenu
                        Controls.MenuItem {
                            text: qsTr("Copy Path")
                            onTriggered: {
                                Backend.copyToClipboard(delegate.url);  // qmllint disable unqualified
                            }
                        }
                        Controls.MenuItem {
                            text: delegate.isHidden ? qsTr("Unhide") : qsTr("Hide")
                            onTriggered: {
                                if (delegate.isHidden) {
                                    Backend.unhideFile(root.folder, delegate.filename);  // qmllint disable unqualified
                                } else {
                                    Backend.hideFile(root.folder, delegate.filename);  // qmllint disable unqualified
                                }
                                root.refreshFolder();
                            }
                        }
                    }
                }
            }
        }
    }
}
