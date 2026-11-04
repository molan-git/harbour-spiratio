import QtQuick 2.0
import Sailfish.Silica 1.0

/*
 * Draws one full breathing cycle as a line:
 *   inhale = rising line, exhale = falling line, hold = horizontal line.
 * A dot travels along the line showing the current position in the cycle.
 */
Canvas {
    id: canvas

    property var phases: []          // [{t,s}, ...]
    property real cycleTime: 1       // total seconds of one cycle
    property real timeInCycle: 0     // current position in the cycle (seconds)
    property color lineColor: Theme.highlightColor
    property color dotColor: Theme.primaryColor
    property int lineThickness: Math.max(3, Theme.paddingSmall)
    property real dotRadius: Math.max(10, Theme.paddingMedium)

    onPhasesChanged: requestPaint()
    onCycleTimeChanged: requestPaint()
    onTimeInCycleChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        var w = width, h = height
        ctx.clearRect(0, 0, w, h)
        if (!phases || phases.length === 0 || cycleTime <= 0)
            return

        var pad = h * 0.15
        var top = pad
        var bottom = h - pad
        var xs = w / cycleTime
        var i, p, nx

        // The line path
        ctx.strokeStyle = lineColor
        ctx.lineWidth = lineThickness
        ctx.lineJoin = "round"
        ctx.lineCap = "round"
        ctx.beginPath()
        var x = 0
        var y = bottom   // start fully exhaled
        ctx.moveTo(x, y)
        var v = 0
        for (i = 0; i < phases.length; i++) {
            p = phases[i]
            nx = x + p.s * xs
            if (p.t === "in") {
                y = top; v = 1
            } else if (p.t === "out") {
                y = bottom; v = 0
            } else {
                y = (v === 1) ? top : bottom
            }
            ctx.lineTo(nx, y)
            x = nx
        }
        ctx.stroke()

        // Moving dot
        var pos = pointAt(timeInCycle)
        ctx.fillStyle = dotColor
        ctx.beginPath()
        ctx.arc(pos.x, pos.y, dotRadius, 0, Math.PI * 2)
        ctx.fill()
    }

    function pointAt(t) {
        var pad = height * 0.15
        var top = pad
        var bottom = height - pad
        var xs = cycleTime > 0 ? width / cycleTime : 0
        var time0 = 0
        var v0 = 0
        for (var i = 0; i < phases.length; i++) {
            var p = phases[i]
            var time1 = time0 + p.s
            // target volume: 1 = full, 0 = empty; holds keep the current volume
            var v1 = (p.t === "in") ? 1 : (p.t === "out") ? 0 : v0
            if (t <= time1) {
                var f = p.s > 0 ? (t - time0) / p.s : 0
                var v = v0 + f * (v1 - v0)
                return { x: t * xs, y: bottom - v * (bottom - top) }
            }
            time0 = time1
            v0 = v1
        }
        // t beyond the cycle (rounding): sit at the end point
        return { x: cycleTime * xs, y: bottom - v0 * (bottom - top) }
    }
}
