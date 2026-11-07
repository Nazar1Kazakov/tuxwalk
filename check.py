"""Render the vector preview and check CPU phase boundaries without loading the shell."""
import os
os.environ["QT_QPA_PLATFORM"] = "offscreen"
from pathlib import Path
from PySide6.QtCore import QTimer, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, QJSEngine
from PySide6.QtQuick import QQuickWindow

root = Path(__file__).resolve().parent
app = QGuiApplication([])
js = QJSEngine()
js.evaluate((root / "components/TuxMotion.js").read_text().replace(".pragma library", ""))
for load, phase, expected in [
    (0, "", "sleep"), (4.99, "", "sleep"), (5, "", "walk"),
    (14.99, "walk", "walk"), (15, "walk", "run"), (100, "sleep", "run"),
    (5.9, "sleep", "sleep"), (6, "sleep", "walk"),
    (14, "run", "run"), (13.9, "run", "walk"), (0, "run", "sleep"),
]:
    result = js.evaluate(f'phaseFor({load}, "{phase}")').toString()
    assert result == expected, (load, phase, result, expected)
assert js.evaluate('phaseFor(NaN, "walk")').toString() == "walk"
print("12 CPU transition checks passed")
engine = QQmlApplicationEngine()
engine.load(QUrl.fromLocalFile(str(root / "preview.qml")))
assert engine.rootObjects(), "Preview failed to load"
def capture():
    window = engine.rootObjects()[0]
    assert window.grabWindow().save(str(root / "media/preview.png"))
    print("Saved media/preview.png")
    app.quit()
QTimer.singleShot(700, capture)
app.exec()
