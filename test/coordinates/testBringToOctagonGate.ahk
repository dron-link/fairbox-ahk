#Requires AutoHotkey v1.1

testBringToOctagonGate() {
    global GATE_MAX_RADIUS, global xComp, global yComp
    OutputDebug, % "testBringToOctagonGate() to start. Results go into log file.`n"
    logAppend("`ntestBringToOctagonGate()")
    x := -128
    Loop {
        y := -128
        Loop {
            isInOctagonGate(x, y)
            y += 1
        } Until y > 128
        x += 1
    } Until x > 128
    logAppend("testBringToOctagonGate(): test concluded.`n")
}

mirrorSet := [[103,0]]
mirrorSet.Push([102,0],[102,1],[102,2],[101,2],[101,3],[101,4],[100,4],[100,5],[100,6],[100,7])
mirrorSet.Push([99,7],[99,8],[99,9],[98,9],[98,10])
mirrorSet.Push([98,11],[98,12],[97,12],[97,13],[97,14],[96,14],[96,15],[96,16],[95,16],[95,17],[95,18])
mirrorSet.Push([95,19],[94,19],[94,20],[94,21],[93,21],[93,22],[93,23],[93,24],[92,24],[92,25],[92,26])
mirrorSet.Push([91,26],[91,27],[91,28],[90,28],[90,29],[90,30],[90,31],[89,31],[89,32],[89,33],[88,33])
mirrorSet.Push([88,34],[88,35],[88,36],[87,36],[87,37],[87,38],[86,38],[86,39],[86,40],[86,41],[85,41])
mirrorSet.Push([85,42],[85,43],[84,43],[84,44],[84,45],[83,45],[83,46],[83,47],[83,48],[82,48],[82,49])
mirrorSet.Push([82,50],[81,50],[81,51],[81,52],[81,53],[80,53],[80,54],[80,55],[79,55],[79,56],[79,57])
mirrorSet.Push([78,57],[78,58],[78,59],[78,60],[77,60],[77,61],[77,62],[76,62],[76,63],[76,64],[76,65])
mirrorSet.Push([75,65],[75,66],[75,67],[74,67],[74,68],[74,69],[74,70],[73,70],[73,71],[73,72],[72,72])

isInOctagonGate(parameterX, parameterY) {
    global xComp, global yComp, global mirrorSet
    testGateCoords := bringToOctagonGate([parameterX, parameterY])
    x := testGateCoords[xComp], y := testGateCoords[yComp]

    mirrorFirst := Abs(x) >= Abs(y) ? Abs(x) : Abs(y)
    mirrorSecond := Abs(x) >= Abs(y) ? Abs(y) : Abs(x)

    isGate := false
    for index, mirrorArray in mirrorSet {
        if (mirrorFirst == mirrorArray[1] and mirrorSecond == mirrorArray[2]) {
            isGate := true
        }
    }
    if !isGate {
        logAppend("Not found in octagon gate coordinates set. "
            . " xIn " parameterX " yIn " parameterY " xOut " x " yOut " y)
    }
    return
}