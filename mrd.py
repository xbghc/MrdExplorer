# requestImage() 传入的 id格式应该是:
#   "path/image_num"
#   image_num的值为0开始的整数
#
# 图片大小为kdata的原始大小
# 一次性只有一个path， 为了节省内存，当path改变时，会重新加载图片

import os
from PySide6.QtQuick import QQuickImageProvider
from PySide6.QtCore import QObject, Signal

from utils import loadImagesFromMrdFile, numpy_to_qimage_grayscale
from sys import platform


class MrdImageProvider(QQuickImageProvider):
    def __init__(self, bridge):
        super().__init__(QQuickImageProvider.Image)
        self.images = {}  # 因为channel不一定是连续的，所以用字典
        self.path = ""
        self.bridge = bridge

    def requestImage(self, id, size, requestedSize):
        parts = id.split("/")
        image_num = int(parts[-1])
        if platform == "win32":
            path = "\\".join(parts[:-1])
        else:
            path = "/".join(parts[:-1])

        if os.path.exists(path + '.mrd'):
            path += '.mrd'
        elif os.path.exists(path + '.MRD'):
            path += '.MRD'
        else:
            raise ValueError
        self.loadImages(path)

        if not os.path.isdir(path):
            channel_num = path.split(".")[-2][-1]
        image = self.images[channel_num][image_num]
        image = numpy_to_qimage_grayscale(image)

        return image

    def updateImage(self, image):
        self.image = image

    def loadImages(self, path):
        if not path.split("#")[0] == self.path:
            self.images = {}
            self.path = path.split("#")[0]
        elif path.split(".")[-2][-1] in self.images:
            return

        if os.path.isdir(path):
            pathList = [os.path.join(path, fname) for fname in
                        os.listdir(path)]
        else:
            pathList = [path]

        for path in pathList:
            images = loadImagesFromMrdFile(path)
            channel_num = path.split(".")[-2][-1]
            self.images[channel_num] = images

        # 图片自己归一化
        # for key in self.images.keys():
        #     for i in range(len(self.images[key])):
        #         self.images[key][i] = self.images[key][i] * 255 / self.images[key][i].max() 

        # 一个线圈做归一化
        for key in self.images.keys():
            max_value = 0
            # min_value = 1e6
            for i in range(len(self.images[key])):
                max_value = max(max_value, self.images[key][i].max())
                # min_value = min(min_value, self.images[key][i].min())
            for i in range(len(self.images[key])):
                # self.images[key][i] = (self.images[key][i]-min_value) * 255 / (max_value - min_value)
                self.images[key][i] = self.images[key][i] / max_value * 255

        # 全局归一化
        # max_value = 0
        # for key in self.images.keys():
        #     for i in range(len(self.images[key])):
        #         max_value = max(max_value, self.images[key][i].max())
        # for key in self.images.keys():
        #     for i in range(len(self.images[key])):
        #         self.images[key][i] = self.images[key][i] / max_value * 255

        # 一张切片的不同线圈之间归一化
        # for i in range(len(self.images['1'])):
        #     max_value = 0
        #     min_value = 1e6
        #     for key in self.images.keys():
        #         max_value = max(max_value, self.images[key][i].max())
        #         min_value = min(min_value, self.images[key][i].min())    
        #     for key in self.images.keys():
        #         self.images[key][i] = (self.images[key][i]-min_value) * 255 / (max_value - min_value) 

        # 传递给qml通道数和图片数改变了
        # 所有通道的图片数都是一样的，随便取一个
        self.bridge.imagesChanged.emit(
            list(self.images.keys()),
            len(self.images[channel_num]))


class MrdImageProviderBridge(QObject):
    imagesChanged = Signal(list, int)
