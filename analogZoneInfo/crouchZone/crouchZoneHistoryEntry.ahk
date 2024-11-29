#Requires AutoHotkey v1.1

class crouchZoneHistoryEntry {
    __New(zone, timestamp, uncrouch) {
        this.zone := zone
        this.timestamp := timestamp
        this.uncrouch := uncrouch
    }
}