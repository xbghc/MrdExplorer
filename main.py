import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from mrd import MrdImageProvider
from backend import Backend # noqa E703

if __name__ == "__main__":
    app = QGuiApplication()

    engine = QQmlApplicationEngine()

    provider = MrdImageProvider()
    # 注册image provider
    engine.addImageProvider("mrd", provider)

    engine.load("Main/Main.qml")
    ex = app.exec()
    sys.exit(ex)
