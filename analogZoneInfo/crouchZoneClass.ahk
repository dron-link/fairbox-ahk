#Requires AutoHotkey v1.1

class baseCrouchZone {
    string := "crouchZone"

    unsaved := new crouchZoneHistoryEntry(false, -1000)
    queue := {}
    saved := new crouchZoneHistoryEntry(false, -1000)
    saveHistory() {
        this.saved := this.unsaved
        this.queue := {}
        return
    }
    zoneOf(aX, aY) {
        return getCrouchZoneOf(aX, aY)
    }
    storeInfoBeforeMultipressEnds(aX, aY) {
        return storeCrouchZoneInfoBeforeMultipressEnds(aX, aY, this)
    }

}