#Requires AutoHotkey v1.1

class pivotTrackAndNerfObject extends pivotHistoryObject {
    wasNerfed := false
    nerfedCoords := false ; at any point in time this will be either a false or a 2 integers array

    pivotNerfSearch(dashZone, outOfDeadzone, aX, aY) {
        global TIMELIMIT_SIMULTANEOUS, global xComp, global yComp, global currentTimeMS

        this.wasNerfed := false ; pivot hasn't been nerfed yet

        ; we nerf if the technique was completed in the near past
        if this.lockout.did {
            this.generatePivotNerfedCoords(outOfDeadzone, aX, aY, this.lockout)
        }

        /*  !this.wasNerfed we take care to not nerf the coordinates again.

            getDashZoneOf(aX) != dashZone.saved.zone is an inoffensive check that can save
            us cpu instructions. ignore this when analyzing.
        */
        if (!this.wasNerfed and getDashZoneOf(aX) != dashZone.saved.zone) {
            ; check if there's a new pivot by the player
            currentPivotInfo := getCurrentPivotInfo(this.saved, this.queue
                , getPivotDid(dashZone, getDashZoneOf(aX)))
            if currentPivotInfo.did {
                this.generatePivotNerfedCoords(outOfDeadzone, aX, aY, currentPivotInfo)
            }
        }
        return
    }

    generatePivotNerfedCoords(outOfDeadzone, aX, aY, pivotInstance) {
        ; special Get that returns false when the coordinates didn't need a nerf
        this.nerfedCoords := getPivotLockoutNerfedCoords([aX, aY], outOfDeadzone, pivotInstance)
        if this.nerfedCoords { ; true if nerfedCoords is an array
            this.wasNerfed := true
        } else {
            this.wasNerfed := false
        }
        return
    }
}