import QtQuick
import QtQuick.Controls
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.services
import "TuxMotion.js" as Motion

StyledRect {
    id: root

    readonly property bool isHorizontal: Config.bar.position === "top" || Config.bar.position === "bottom"
    readonly property real cpuPercent: Math.max(0, Math.min(100, Cpu.percentage * 100))
    property real smoothedLoad: cpuPercent
    property string phase: "sleep"
    property bool sampled: false
    readonly property string activity: phase === "sleep" ? "Sleeping" : phase === "walk" ? "Walking" : "Running"

    implicitWidth: isHorizontal ? Tokens.sizes.bar.innerWidth * 1.5 : Tokens.sizes.bar.innerWidth
    implicitHeight: isHorizontal ? Tokens.sizes.bar.innerWidth : Tokens.sizes.bar.innerWidth * 1.25
    color: Colours.tPalette.m3surfaceContainer
    radius: Tokens.rounding.full
    clip: true

    Accessible.name: "Penguin: " + activity + ", CPU " + Math.round(cpuPercent) + "%"
    Accessible.role: Accessible.Indicator

    ServiceRef {
        service: Cpu
    }

    // Share Caelestia's native CPU sampler, including on multi-monitor setups.
    // Only classification is sampled here; there are no subprocesses or /proc polls.
    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!Number.isFinite(root.cpuPercent))
                return;
            root.smoothedLoad = root.sampled ? root.smoothedLoad * 0.55 + root.cpuPercent * 0.45 : root.cpuPercent;
            root.phase = Motion.phaseFor(root.smoothedLoad, root.sampled ? root.phase : "");
            root.sampled = true;
        }
    }

    TuxSprite {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -2
        width: parent.width - Tokens.padding.extraSmall
        height: Math.min(parent.height - 8, width * 40 / 48)
        phase: root.phase
        fur: Colours.palette.m3primary
        detail: Colours.palette.m3onPrimary
    }

    // Quiet load indicator underneath the penguin; no extra label in the narrow bar.
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        width: parent.width * 0.45
        height: 2
        radius: 1
        color: Qt.alpha(Colours.palette.m3primary, 0.13)

        Rectangle {
            width: parent.width * root.cpuPercent / 100
            height: parent.height
            radius: parent.radius
            color: Colours.palette.m3primary
            Behavior on width {
                NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
            }
        }
    }

    HoverHandler { id: hover }

    ToolTip {
        id: tip
        visible: hover.hovered
        delay: 500
        text: "Penguin · " + root.activity + "\nCPU " + Math.round(root.cpuPercent) + "%"
        font: Tokens.font.body.small
        contentItem: StyledText {
            text: tip.text
            font: Tokens.font.body.small
            color: Colours.palette.m3onSurface
        }
        background: Rectangle {
            color: Colours.palette.m3surfaceContainerHigh
            radius: Tokens.rounding.small
            border.color: Colours.palette.m3outlineVariant
        }
    }
}
