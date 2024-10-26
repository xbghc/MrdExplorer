# requestImage() 传入的 id格式应该是:
#   "path/channel_num/image_num"
#   其中channel_num和image_num的值为0开始的整数
#
# 图片大小为kdata的原始大小
# 一次性只有一个path， 为了节省内存，当path改变时，会重新加载图片

import os
from PySide6.QtQuick import QQuickImageProvider
from PySide6.QtCore import QObject, Signal
from PySide6.QtQml import QmlElement

from utils import loadImagesFromMrdFile, numpy_to_qimage_grayscale
from sys import platform


QML_IMPORT_NAME = "myMrdImageProvider"
QML_IMPORT_MAJOR_VERSION = 1


class MrdImageProvider(QQuickImageProvider):
    def __init__(self, bridge):
        super().__init__(QQuickImageProvider.Image)
        self.images = {}  # 因为channel不一定是连续的，所以用字典
        self.path = ""
        self.bridge = bridge

    def requestImage(self, id, size, requestedSize):
        parts = id.split("/")
        image_num = int(parts[-1])
        channel_num = parts[-2]
        if platform == "win32":
            path = "\\".join(parts[:-2])
        else:
            path = "/".join(parts[:-2])

        self.loadImages(path)

        if not os.path.isdir(path):
            channel_num = path.split(".")[-2][-1]
        image = self.images[channel_num][image_num]
        image = numpy_to_qimage_grayscale(image)

        return image

    def updateImage(self, image):
        self.image = image

    def loadImages(self, path):
        if path == self.path:
            return
        self.path = path
        self.images = {}

        if os.path.isdir(path):
            pathList = [os.path.join(path, fname) for fname in
                        os.listdir(path)]
        else:
            pathList = [path]

        for path in pathList:
            images = loadImagesFromMrdFile(path)
            channel_num = path.split("#")[-1].split(".")[0]
            self.images[channel_num] = images

        # 传递给qml通道数和图片数改变了
        self.bridge.channelsChanged.emit(self.images.keys())
        # 所有通道的图片数都是一样的，随便取一个
        self.bridge.slicesChanged.emit(len(self.images[channel_num]))


@QmlElement
class MrdImageProviderBridge(QObject):
    channelsChanged = Signal(list)
    slicesChanged = Signal(int)
