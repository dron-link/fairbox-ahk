#Requires AutoHotkey v1.1

#include, crouchZoneHistoryObject.ahk
#include, getCrouchZone.ahk

class crouchZoneHistoryEntry {
    __New(zone, timestamp) {
        this.zone := zone
        this.timestamp := timestamp
    }
}