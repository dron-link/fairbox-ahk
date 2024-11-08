#Requires AutoHotkey v1.1

class pivotTrackAndNerfObject extends pivotHistoryObject {
    wasNerfed := false
    nerfedCoords := ""

    nerfSearch(aX, aY, dashZone) {
        global TIMELIMIT_SIMULTANEOUS, global xComp, global yComp, global currentTimeMS

        this.wasNerfed := false ; pivot hasn't been nerfed yet

        ; we nerf if the technique was completed in the near past
        if this.lockout.did {
            this.generateNerfedCoords(aX, aY, this.lockout)
        }
        ; we are able to overwrite aX and aY with nerfed values for the next steps
        if this.wasNerfed {
            aX := this.nerfedCoords[xComp], aY := this.nerfedCoords[yComp]
        }

        ; this check is unnecessary but, if it failed, new empty pivot would be doomed anyways 
        if (getDashZoneOf(aX, aY) != dashZone.saved.zone) {
            currentPivotInfo := getCurrentPivotInfo(aX, aY, getPivotDirection(aX, aY, dashZone), this)
            ; take care to not nerf the same coordinates twice
            if (currentPivotInfo.did and !this.wasNerfed) {
                this.generateNerfedCoords(aX, aY, currentPivotInfo)
            }
        }
        return
    }

    generateNerfedCoords(aX, aY, pivotInstance) {
        this.nerfedCoords := getPivotLockoutNerfedCoords(aX, aY, pivotInstance, this)
        if this.nerfedCoords {
            this.wasNerfed := true
        } else {
            this.wasNerfed := false
        }
        return
    }
}