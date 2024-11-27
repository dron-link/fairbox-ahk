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

        /*  !this.wasNerfed: we take care to not nerf the coordinates again.

            getCrouchZoneOf(aY) != crouchZoneSavedZone is an inoffensive check that can save
            us cpu instructions. ignore this when analyzing.
        */
        if (!this.wasNerfed and getCrouchZoneOf(aY) != crouchZoneSavedZone) {
            ; check if there's a new uncrouch by the player
            currentUncrouchInfo := getCurrentUncrouchInfo(this.saved, this.queue
                , getUncrouchDid(crouchZoneSavedZone, getCrouchZoneOf(aY)))
            if currentUncrouchInfo.did {
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