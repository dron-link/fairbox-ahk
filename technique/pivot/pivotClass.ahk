#Requires AutoHotkey v1.1

class basePivot {
    string := "pivot"

    unsaved := new pivotInfo(false, -1000)
    queue := {}
    saved := new pivotInfo(false, -1000)
    lockout := new pivotInfo(false, -1000)

    wasNerfed := false
    nerfedCoords := ""

    saveHistory() {
        if (this.unsaved.did and this.unsaved.did != this.saved.did) {
            this.lockout := this.unsaved
        }
        this.saved := this.unsaved
        this.queue := {}
    }

    lockoutExpiryCheck() {
        global TIMELIMIT_PIVOTTILT, global currentTimeMS
        if (this.lockout.did and currentTimeMS - this.lockout.timestamp >= TIMELIMIT_PIVOTTILT) {
            this.lockout := new pivotInfo(false, currentTimeMS)
        }
        return
    }

    detect(aX, aY, dashZone) {
        return detectPivot(aX, aY, dashZone)
    }
    nerfSearch(aX, aY, dashZone) {
        return nerfBasedOnHistory(aX, aY, dashZone, pivotInfo, this)
    }
    generateNerfedCoords(aX, aY, pivotInstance) {
        this.nerfedCoords := getPivotLockoutNerfedCoords(aX, aY, pivotInstance, this)
        return
    }
    getCurrentInfo(aX, aY, dashZone) {
        return getCurrentPivotInfo(aX, aY, detectPivot(aX, aY, dashZone), this)
    }
    storeInfoBeforeMultipressEnds(aX, aY, dashZone) {
        return storePivotsBeforeMultipressEnds(aX, aY, detectPivot(aX, aY, dashZone), this)
    }
}