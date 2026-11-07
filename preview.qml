import QtQuick
import QtQuick.Window
import "components"
Window {
    width: 680
    height: 250
    visible: true
    color: "#16131d"
    Row {
        anchors.centerIn: parent
        spacing: 18
        Repeater {
            model: ["sleep", "walk", "run"]
            delegate: Rectangle {
                required property string modelData
                width: 192
                height: 190
                radius: 28
                color: "#24202e"
                CatSprite {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 22
                    width: 150
                    height: 125
                    phase: parent.modelData
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 150
                    text: parent.modelData === "sleep" ? "SLEEP · < 5%" : parent.modelData === "walk" ? "WALK · 5–15%" : "RUN · ≥ 15%"
                    color: "#cbbfff"
                    font.pixelSize: 13
                    font.family: "sans-serif"
                }
            }
        }
    }
}
