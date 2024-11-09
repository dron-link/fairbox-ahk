#Requires AutoHotkey v1.1

class outputHistoryEntry {
    __New(x, y, timestamp) {
        ;         1            2                    3
        this.x := x, this.y := y, this.timestamp := timestamp
        this.multipress := {began : false, ended : false}
    }
}