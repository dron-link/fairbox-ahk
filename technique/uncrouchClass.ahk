#Requires AutoHotkey v1.1

class baseUncrouch {
    string:="uncrouch"

    unsaved := new uncrouchInfo(false, -1000)
    queue := {}
    saved := new uncrouchInfo(false, -1000)
    lockout := new uncrouchInfo(false, -1000)

    wasNerfed := false
    nerfedCoords := ""

    saveHistory() {
        if (this.unsaved.did and this.unsaved.did != this.saved.did) {
            this.lockout := this.unsaved
        }
        this.saved := this.unsaved, this.queue := {}
        return
    }

    lockoutExpiryCheck() {
        global TIMELIMIT_DOWNUP, global currentTimeMS
        if (this.lockout.did and currentTimeMS - this.lockout.timestamp >= TIMELIMIT_DOWNUP) {
            this.lockout := new uncrouchInfo(false, currentTimeMS)
        }
        return
    }

    detect(aX, aY, crouchZone) {
        return detectUncrouch(aX, aY, crouchZone)
    }
    nerfSearch(aX, aY, crouchZone) {
        return nerfBasedOnHistory(aX, aY, crouchZone, uncrouchInfo, this)
    }
    generateNerfedCoords(aX, aY, uncrouchInstance) {
        this.nerfedCoords := getUncrouchLockoutNerfedCoords(aX, aY, uncrouchInstance, this)
        return
    }
    getCurrentInfo(aX, aY, crouchZone) {
        return getCurrentUncrouchInfo(aX, aY, detectUncrouch(aX, aY, crouchZone), this)
    }
    storeInfoBeforeMultipressEnds(aX, aY, crouchZone) {
        return storeUncrouchesBeforeMultipressEnds(aX, aY, detectUncrouch(aX, aY, crouchZone), this)
    }
}