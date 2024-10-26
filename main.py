import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQuick import QQuickView

from mrd import MrdImageProvider, MrdImageProviderBridge

if __name__ == "__main__":
    app = QGuiApplication()
    view = QQuickView()

    engine = view.engine()
    engine.addImportPath(sys.path[0])

    bridge = MrdImageProviderBridge()
    provider = MrdImageProvider(bridge)
    # 注册image provider
    engine.addImageProvider("mrd", provider)
    engine.rootContext().setContextProperty(
        "imageBridge", bridge)

    view.loadFromModule("Main", "Main")
    view.show()
    ex = app.exec()
    del view
    sys.exit(ex)
