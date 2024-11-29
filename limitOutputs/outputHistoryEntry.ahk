#Requires AutoHotkey v1.1

class outputHistoryEntry {
    __New(x, y, timestamp, multipressBegan) {
        ;         1            2                    3
        this.x := x, this.y := y, this.timestamp := timestamp
        ;                           4
        this.multipress := {began : multipressBegan, ended : false}
    }
}