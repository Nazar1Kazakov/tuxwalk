import QtQuick
import QtQuick.Window
import "components"

Window {
    id: root
    width: 960
    height: 360
    visible: true
    color: "#101116"
    title: "TuxWalk preview"

    Text {
        x: 34
        y: 22
        text: "TuxWalk"
        color: "#f4f4f4"
        font.family: "sans-serif"
        font.bold: true
        font.pixelSize: 30
    }
    Text {
        x: 200
        y: 32
        text: "an animated penguin for the Caelestia bar"
        color: "#a6a6a6"
        font.family: "sans-serif"
        font.pixelSize: 16
    }

    Row {
        x: 34
        y: 78
        spacing: 18
        Repeater {
            model: ["sleep", "walk", "run"]
            delegate: Rectangle {
                required property string modelData
                width: 285
                height: 245
                radius: 20
                color: "#202127"
                border.color: "#383a42"
                border.width: 1

                TuxSprite {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 14
                    width: 220
                    height: 183
                    phase: parent.modelData
                    fur: "#b9b9b9"
                    detail: "#404040"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 207
                    text: parent.modelData === "sleep" ? "SLEEP  ·  < 5% CPU" : parent.modelData === "walk" ? "WALK  ·  5–15% CPU" : "RUN  ·  ≥ 15% CPU"
                    color: "#e8e8e8"
                    font.family: "sans-serif"
                    font.bold: true
                    font.pixelSize: 16
                }
            }
        }
    }
}
