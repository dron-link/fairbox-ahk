#Requires AutoHotkey v1.1

class uncrouchTrackAndNerfObject extends uncrouchHistoryObject {
    wasNerfed := false
    nerfedCoords := false

    uncrouchNerfSearch(crouchZoneSavedZone, aX, aY) {
        global TIMELIMIT_SIMULTANEOUS, global xComp, global yComp, global currentTimeMS

        this.wasNerfed := false ; uncrouch hasn't been nerfed yet

        ; we nerf if the technique was completed in the near past
        if this.lockout.did {
            this.generateUncrouchNerfedCoords(aX, aY, this.lockout.timestamp)
        }

        ; we are able to overwrite aX and aY with nerfed values, just for the next steps
        if this.wasNerfed {
            aX := this.nerfedCoords[xComp], aY := this.nerfedCoords[yComp]
        }

        /*  this check is unnecessary but, if it failed, a new uncrouch would be logically impossible
            and this saves us cpu instructions
        */
        if (getCrouchZoneOf(aY) != crouchZoneSavedZone) {
            currentUncrouchInfo := getCurrentUncrouchInfo(this.saved, this.queue
                , getUncrouchDid(crouchZoneSavedZone, getCrouchZoneOf(aY)))
            ; if there's a current uncrouch atop the lockout one, take care to not nerf the coordinates again
            if (currentUncrouchInfo.did and !this.wasNerfed) {
                this.generateUncrouchNerfedCoords(aX, aY, currentUncrouchInfo.timestamp)
            }
        }
        return
    }

    generateUncrouchNerfedCoords(aX, aY, uncrouchTimestamp) {
        ; special Get that returns false when the coordinates didn't need a nerf
        this.nerfedCoords := getUncrouchLockoutNerfedCoords([aX, aY], uncrouchTimestamp)
        if this.nerfedCoords {
            this.wasNerfed := true
        } else {
            this.wasNerfed := false
        }
        return
    }
}