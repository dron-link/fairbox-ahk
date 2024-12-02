#Requires AutoHotkey v1.1

fExpectedOutputHist(results) {
    expectedOutputHist := []
    expectedOutputHist.InsertAt(1, {x:0 , y:0})
    expectedOutputHist.InsertAt(1, {x:2 , y:0})
    expectedOutputHist.InsertAt(1, {x:2 , y:2})
    expectedOutputHist.InsertAt(1, {x:0 , y:2})
    expectedOutputHist.InsertAt(1, {x:0 , y:-2})
    expectedOutputHist.InsertAt(1, {x:-2 , y:-2})
    expectedOutputHist.InsertAt(1, {x:-2 , y:0})
    expectedOutputHist.InsertAt(1, {x:0 , y:0})

    if (results.output.historyLength != results.output.hist.Length()) {
        OutputDebug, % "expectedOutputHist warning #1. hist is not the correct size`n"
    }
    Loop, 8{
        if (A_Index > results.output.hist.Length()) {
            break ; we avoid accessing elements that do not exist
        }

        if (results.output.hist[A_Index].x != expectedOutputHist[A_Index].x
            or results.output.hist[A_Index].y != expectedOutputHist[A_Index].y) {
            OutputDebug, % "expectedOutputHist warning #2. something was not expected`n"
            break
        }   
    }
    
    OutputDebug, % "expectedOutputHist test finish`n`n"
    return
}