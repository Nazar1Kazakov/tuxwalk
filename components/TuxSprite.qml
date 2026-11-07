import QtQuick

// Vector artwork stays crisp at any bar scale and follows the live palette.
Canvas {
    id: root

    property string phase: "sleep"
    property color fur: "#cbbfff"
    property color detail: "#302b40"
    property real cycle: 0
    property bool animated: true
    readonly property bool sleeping: phase === "sleep"

    implicitWidth: 44
    implicitHeight: 36
    renderStrategy: Canvas.Cooperative

    onCycleChanged: requestPaint()
    onPhaseChanged: requestPaint()
    onFurChanged: requestPaint()
    onDetailChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    // 12 fps while asleep; 30 fps in motion. No external sprite process.
    Timer {
        interval: root.sleeping ? 83 : 33
        running: root.visible && root.animated
        repeat: true
        onTriggered: root.cycle = (root.cycle + interval / (root.sleeping ? 3200 : root.phase === "walk" ? 900 : 420)) % 1
    }

    onPaint: {
        const c = getContext("2d");
        c.reset();
        c.scale(width / 48, height / 40);
        c.lineCap = "round";
        c.lineJoin = "round";
        const t = root.cycle * Math.PI * 2;

        function ellipse(x, y, rx, ry, colour) {
            c.save();
            c.translate(x, y);
            c.scale(rx, ry);
            c.beginPath();
            c.arc(0, 0, 1, 0, Math.PI * 2);
            c.fillStyle = colour;
            c.fill();
            c.restore();
        }
        function stroke(points, colour, thickness) {
            c.beginPath();
            c.moveTo(points[0], points[1]);
            for (let i = 2; i < points.length; i += 2)
                c.lineTo(points[i], points[i + 1]);
            c.strokeStyle = colour;
            c.lineWidth = thickness;
            c.stroke();
        }
        const running = root.phase === "run";
        const sleeping = root.sleeping;
        const bob = sleeping ? Math.sin(t) * 0.4 : Math.cos(t * 2) * (running ? 1.7 : 0.65);
        const stride = sleeping ? 0 : Math.sin(t) * (running ? 3.2 : 1.7);
        const wingLift = sleeping ? 0 : Math.sin(t + Math.PI / 2) * (running ? 4 : 2);
        const body = root.detail;
        const belly = root.fur;

        ellipse(24, 37, 15, 1.3, Qt.alpha(root.fur, 0.14));
        c.save();
        c.translate(0, bob);

        // Feet and flippers sit behind the rounded penguin body.
        ellipse(18 - stride, 34.5, 5.2, 2, root.fur);
        ellipse(30 + stride, 34.5, 5.2, 2, root.fur);
        c.fillStyle = root.fur;
        c.beginPath();
        c.moveTo(15, 20);
        c.quadraticCurveTo(8 - wingLift, 23, 11 - wingLift, 31);
        c.quadraticCurveTo(14, 32, 18, 27);
        c.moveTo(33, 20);
        c.quadraticCurveTo(40 + wingLift, 23, 37 + wingLift, 31);
        c.quadraticCurveTo(34, 32, 30, 27);
        c.fill();

        ellipse(24, 23, 12.5, 14, root.fur);
        ellipse(24, 23, 11.3, 12.8, body);
        ellipse(24, 25, 7.5, 9, belly);
        ellipse(24, 13, 10, 9, root.fur);
        ellipse(24, 13, 8.8, 7.8, body);

        if (sleeping) {
            stroke([19, 14, 21, 15, 22, 14], root.fur, 1.2);
            stroke([26, 14, 27, 15, 29, 14], root.fur, 1.2);
        } else {
            ellipse(21, 14, 1.3, 1.5, root.fur);
            ellipse(27, 14, 1.3, 1.5, root.fur);
        }
        c.fillStyle = root.fur;
        c.beginPath();
        c.moveTo(22, 17);
        c.lineTo(26, 17);
        c.lineTo(24, 20);
        c.closePath();
        c.fill();
        c.restore();

        if (sleeping) {
            c.fillStyle = Qt.alpha(root.fur, 0.7 - root.cycle * 0.45);
            c.font = "bold 8px sans-serif";
            c.fillText("z", 32 + root.cycle * 3, 9 - root.cycle * 4);
            c.font = "bold 6px sans-serif";
            c.fillText("z", 39 + root.cycle * 2, 5 - root.cycle * 3);
        }
        if (running) {
            c.globalAlpha = 0.25;
            stroke([7, 32, 11, 32], root.fur, 1.2);
            stroke([5, 35, 10, 35], root.fur, 1.2);
            c.globalAlpha = 1;
        }
    }
}
