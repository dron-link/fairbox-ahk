#Requires AutoHotkey v1.1

class uncrouchTrackAndNerfObject extends uncrouchHistoryObject {
    wasNerfed := false
    nerfedCoords := false

    nerfSearch(aX, aY, crouchZone) {
        global TIMELIMIT_SIMULTANEOUS, global xComp, global yComp, global currentTimeMS

        this.wasNerfed := false ; uncrouch hasn't been nerfed yet

        ; we nerf if the technique was completed in the near past
        if this.lockout.did {
            this.generateNerfedCoords(aX, aY, this.lockout)
        }

        ; we are able to overwrite aX and aY with nerfed values, just for the next steps
        if this.wasNerfed {
            aX := this.nerfedCoords[xComp], aY := this.nerfedCoords[yComp]
        }

        ; this check is unnecessary but, if it failed, new uncrouch uptilt would be doomed anyways
        if (getCrouchZoneOf(aX, aY) != crouchZone.saved.zone) {
            currentUncrouchInfo := getCurrentUncrouchInfo(aX, aY, getUncrouchDid(aX, aY, crouchZone), this)
            ; if there's a current uncrouch atop the lockout one, take care to not nerf the coordinates again
            if (currentUncrouchInfo.did and !this.wasNerfed) {
                this.generateNerfedCoords(aX, aY, currentUncrouchInfo)
            }
        }
        return
    }

    generateNerfedCoords(aX, aY, uncrouchInstance) {
        this.nerfedCoords := getUncrouchLockoutNerfedCoords([aX, aY], this, uncrouchInstance)
        if this.nerfedCoords {
            this.wasNerfed := true
        } else {
            this.wasNerfed := false
        }
        return
    }
}