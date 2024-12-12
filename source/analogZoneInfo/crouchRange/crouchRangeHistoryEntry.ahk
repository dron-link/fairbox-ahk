#Requires AutoHotkey v1

class crouchRangeHistoryEntry {
    __New(INside, timestamp, uncrouch) {
        this.in := INside
        this.timestamp := timestamp
        this.uncrouch := uncrouch
    }
}