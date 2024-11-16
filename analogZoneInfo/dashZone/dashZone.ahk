#Requires AutoHotkey v1.1

#include, dashZoneHistoryObject.ahk
#include, getDashZone.ahk

class dashZoneHistoryEntry {
    __New(zone, timestamp, stale) {
        this.zone := zone
        this.timestamp := timestamp
        this.stale := stale
    }
}