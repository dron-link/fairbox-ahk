#Requires AutoHotkey v1.1

testBringToOctagonGate() {
    global GATE_MAX_RADIUS, global xComp, global yComp
    OutputDebug, % "`ntestBringToOctagonGate()`n"
    x := -128
    Loop {
        y := -128
        Loop {
                coordsGate := bringToOctagonGate([x, y])
                xGate := coordsGate[xComp], yGate := coordsGate[yComp]
                if (xGate**2 + yGate**2 > GATE_MAX_RADIUS**2) {
                    OutputDebug, % "Overshoot. x " x " y " y " xGate " xGate " yGate " yGate "`n"
                }
                ; accounting for clamping, we are lenient by 1 unit before declaring undershoot
                else if (Sqrt(xGate**2 + yGate**2) < Sqrt(87**2 + 36**2) - 1) { 
                    OutputDebug, % "Undershoot. x " x " y " y " xGate " xGate " yGate " yGate "`n"
                }
            y += 1
        } Until y > 128
        x += 1
    } Until x > 128
    OutputDebug, % "testBringToOctagonGate() finished.`n"
}