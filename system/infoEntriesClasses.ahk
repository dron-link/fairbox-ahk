#Requires AutoHotkey v1.1

class outputHistoryEntry {
    __New(x, y, timestamp) {
        ;         1            2                    3
        this.x := x, this.y := y, this.timestamp := timestamp
        this.multipress := {began : false, ended : false}
    }
}

class outOfDeadzoneInfo {
    __New(boolOut, timestamp) {
        this.out := boolOut
        this.timestamp := timestamp
    }
}

class techniqueClassThatHasTimingLockouts {
    __New(did, timestamp) {
        this.did := did
        this.timestamp := timestamp
    }
}

