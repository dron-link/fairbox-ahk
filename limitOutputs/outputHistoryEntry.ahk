#Requires AutoHotkey v1.1

class outputHistoryEntry {
    pivotWasNerfed := false
    pivotNerfedCoords := false
    uncrouchWasNerfed := false
    uncrouchNerfedCoords := false
    
    __New(x, y, timestamp, multipressBegan) {
        ;         1            2                    3
        this.x := x, this.y := y, this.timestamp := timestamp
        ;                           4
        this.multipress := {began : multipressBegan, ended : false}
    }
}