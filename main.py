import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from mrd import MrdImageProvider, MrdImageProviderBridge
from backend import Backend

if __name__ == "__main__":
    app = QGuiApplication()

    engine = QQmlApplicationEngine()

    bridge = MrdImageProviderBridge()
    provider = MrdImageProvider(bridge)
    # 注册image provider
    engine.addImageProvider("mrd", provider)
    engine.rootContext().setContextProperty("imageBridge", bridge)

    engine.load("Main/Main.qml")
    ex = app.exec()
    sys.exit(ex)
