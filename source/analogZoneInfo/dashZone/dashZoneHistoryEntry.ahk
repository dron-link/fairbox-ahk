#Requires AutoHotkey v1

class dashZoneHistoryEntry {
    __New(zone, timestamp, pivot) {
        this.zone := zone
        this.timestamp := timestamp
        this.pivot := pivot
    }
}