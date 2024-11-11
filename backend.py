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
            raise TypeError

        file_list = os.listdir(d)
        out = []

        for f in file_list:
            u = d + "/" + f  # 不要用os.path.join，QML无法识别
            if os.path.isdir(u):
                out.append({"url": u, "isDir": True, "filename": f})
            else:
                if not (f.endswith(".mrd") or f.endswith(".MRD")):
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

        noImages = 0
        for i in os.listdir(directory):
            if i.startswith(filename):
                noImages = utils.getMrdImagesNum(os.path.join(directory, i))
                break
        if noImages == 0:
            raise ValueError

        channels_list = []
        for f in os.listdir(directory):
            if f.startswith(filename):
                channels_list.append(utils.parseMrdFileName(f)[1])

        out = []
        for i in range(noImages):
            slices = []
            for c in channels_list:
                slices.append(url + "#" + c + "/" + str(i))
            out.append(slices)
        return out
