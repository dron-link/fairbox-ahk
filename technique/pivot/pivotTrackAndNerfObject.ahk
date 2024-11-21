#Requires AutoHotkey v1.1

class pivotTrackAndNerfObject extends pivotHistoryObject {
    wasNerfed := false
    nerfedCoords := false ; this is either a false or a 2 integers array

    nerfSearch(aX, aY, dashZone, outOfDeadzone) {
        global TIMELIMIT_SIMULTANEOUS, global xComp, global yComp, global currentTimeMS

        this.wasNerfed := false ; pivot hasn't been nerfed yet

        ; we nerf if the technique was completed in the near past
        if this.lockout.did {
            this.generateNerfedCoords(aX, aY, outOfDeadzone, this.lockout)
        }

        ; we are able to overwrite parameters aX and aY with nerfed values, just for the next steps
        if this.wasNerfed {
            aX := this.nerfedCoords[xComp], aY := this.nerfedCoords[yComp]
        }

        ; this check is unnecessary but, if it failed, new empty pivot would be doomed anyways 
        if (getDashZoneOf(aX) != dashZone.saved.zone) {
            currentPivotInfo := getCurrentPivotInfo(getDidPivot(aX, dashZone), this.saved, this.queue)
            ; if there's a current pivot atop the lockout pivot, take care to not nerf the coordinates again
            if (currentPivotInfo.did and !this.wasNerfed) {
                this.generateNerfedCoords(aX, aY, outOfDeadzone, currentPivotInfo)
            }
        }
        return
    }

    generateNerfedCoords(aX, aY, outOfDeadzone, pivotInstance) {
        this.nerfedCoords := getPivotLockoutNerfedCoords([aX, aY], outOfDeadzone, pivotInstance)
        if this.nerfedCoords {
            this.wasNerfed := true
        } else {
            this.wasNerfed := false
        }
        return
    }
}