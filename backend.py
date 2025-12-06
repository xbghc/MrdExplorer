from PySide6.QtCore import QObject, Slot, QSettings
from PySide6.QtGui import QGuiApplication, QClipboard
from PySide6.QtQml import QmlElement, QmlSingleton
import os

import utils


QML_IMPORT_NAME = "main.backend"
QML_IMPORT_MAJOR_VERSION = 1

SETTINGS_KEY_LAST_FOLDER = "lastFolder"
SETTINGS_KEY_LAST_FILE = "lastFile"
SETTINGS_KEY_HIDDEN_FILES = "hiddenFiles"


@QmlElement
@QmlSingleton
class Backend(QObject):
    def __init__(self):
        super().__init__()
        self._settings = QSettings("MrdExplorer", "MrdExplorer")

    @Slot(str)
    def saveLastFolder(self, folder: str):
        self._settings.setValue(SETTINGS_KEY_LAST_FOLDER, folder)

    @Slot(result=str)
    def getLastFolder(self) -> str:
        return self._settings.value(SETTINGS_KEY_LAST_FOLDER, "")

    @Slot(str)
    def saveLastFile(self, file_url: str):
        self._settings.setValue(SETTINGS_KEY_LAST_FILE, file_url)

    @Slot(result=str)
    def getLastFile(self) -> str:
        return self._settings.value(SETTINGS_KEY_LAST_FILE, "")

    @Slot(str)
    def copyToClipboard(self, text: str):
        clipboard = QGuiApplication.clipboard()
        clipboard.setText(text)

    def _getHiddenFilesKey(self, directory: str) -> str:
        """生成目录对应的隐藏文件设置键"""
        return f"{SETTINGS_KEY_HIDDEN_FILES}/{directory}"

    @Slot(str, str)
    def hideFile(self, directory: str, filename: str):
        """隐藏指定文件"""
        key = self._getHiddenFilesKey(directory)
        hidden_list = self._settings.value(key, [])
        if not isinstance(hidden_list, list):
            hidden_list = []
        if filename not in hidden_list:
            hidden_list.append(filename)
            self._settings.setValue(key, hidden_list)

    @Slot(str, str)
    def unhideFile(self, directory: str, filename: str):
        """取消隐藏指定文件"""
        key = self._getHiddenFilesKey(directory)
        hidden_list = self._settings.value(key, [])
        if not isinstance(hidden_list, list):
            hidden_list = []
        if filename in hidden_list:
            hidden_list.remove(filename)
            self._settings.setValue(key, hidden_list)

    @Slot(str, result=list)
    def getHiddenFiles(self, directory: str) -> list:
        """获取目录下的隐藏文件列表"""
        key = self._getHiddenFilesKey(directory)
        hidden_list = self._settings.value(key, [])
        if not isinstance(hidden_list, list):
            return []
        return hidden_list

    @Slot(str, str, result=bool)
    def isFileHidden(self, directory: str, filename: str) -> bool:
        """检查文件是否被隐藏"""
        hidden_list = self.getHiddenFiles(directory)
        return filename in hidden_list

    @Slot(str, bool, bool, bool, result=list)
    def listdir(self, d, merge_channels, hide_single, show_hidden):
        if not os.path.isdir(d):
            raise NotADirectoryError(f"路径不是目录: {d}")

        file_list = os.listdir(d)
        hidden_files = self.getHiddenFiles(d)
        out = []

        # 先收集所有文件信息，用于计算线圈数量
        coil_counts = {}  # {base_filename: count}
        for f in file_list:
            if f.lower().endswith(".mrd"):
                base_filename, c = utils.parseMrdFileName(f)
                if c is not None:
                    coil_counts[base_filename] = coil_counts.get(base_filename, 0) + 1

        for f in file_list:
            u = d + "/" + f  # 不要用os.path.join，QML无法识别
            if os.path.isdir(u):
                is_hidden = f in hidden_files
                if is_hidden and not show_hidden:
                    continue
                out.append({"url": u, "isDir": True, "filename": f,
                            "coilCount": 0, "isHidden": is_hidden})
            else:
                if not f.lower().endswith(".mrd"):
                    continue
                filename, c = utils.parseMrdFileName(u)
                if hide_single and c is None:
                    continue

                if merge_channels:
                    url = d + "/" + filename
                    is_hidden = filename in hidden_files

                    if is_hidden and not show_hidden:
                        continue

                    exists = False
                    for o in out:
                        if o["url"] == url:
                            exists = True
                            break

                    if not exists:
                        coil_count = coil_counts.get(filename, 1)
                        out.append({"url": url, "isDir": False,
                                    "filename": filename, "coilCount": coil_count,
                                    "isHidden": is_hidden})

                else:
                    is_hidden = f in hidden_files
                    if is_hidden and not show_hidden:
                        continue
                    out.append({"url": u, "isDir": False, "filename": f,
                                "coilCount": 1, "isHidden": is_hidden})

        return out

    @Slot(str, result=list)
    def getImagesSources(self, url):
        directory = os.path.dirname(url)
        filename = os.path.basename(url)

        # 单次目录遍历，同时获取通道列表和图片数量
        file_list = os.listdir(directory)
        matching_files = [f for f in file_list if f.startswith(filename)]

        if not matching_files:
            raise FileNotFoundError(f"找不到匹配的MRD文件: {filename}")

        num_images = utils.getMrdImagesNum(os.path.join(directory, matching_files[0]))
        channels_list = [utils.parseMrdFileName(f)[1] for f in matching_files]

        out = []
        for i in range(num_images):
            slices = [url + "#" + c + "/" + str(i) for c in channels_list]
            out.append(slices)
        return out
