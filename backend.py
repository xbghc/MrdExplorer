from PySide6.QtCore import QObject, Slot
from PySide6.QtQml import QmlElement, QmlSingleton
import os

import utils


QML_IMPORT_NAME = "main.backend"
QML_IMPORT_MAJOR_VERSION = 1


@QmlElement
@QmlSingleton
class Backend(QObject):
    def __init__(self):
        super().__init__()

    @Slot(str, bool, bool, result=list)
    def listdir(self, d, merge_channels, hide_single):
        if not os.path.isdir(d):
            raise NotADirectoryError(f"路径不是目录: {d}")

        file_list = os.listdir(d)
        out = []

        for f in file_list:
            u = d + "/" + f  # 不要用os.path.join，QML无法识别
            if os.path.isdir(u):
                out.append({"url": u, "isDir": True, "filename": f})
            else:
                if not f.lower().endswith(".mrd"):
                    continue
                filename, c = utils.parseMrdFileName(u)
                if hide_single and c is None:
                    continue

                if merge_channels:
                    url = d + "/" + filename

                    exists = False
                    for o in out:
                        if o["url"] == url:
                            exists = True

                    if not exists:
                        out.append({"url": url, "isDir": False,
                                    "filename": filename})

                else:
                    out.append({"url": u, "isDir": False, "filename": f})

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
