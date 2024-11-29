#Requires AutoHotkey v1.1

class outputTrackAndNerfObject extends outputHistoryObject {
    turnaroundNeutralBNerf() {
        global xComp, global yComp
        nerfedCoords := getReverseNeutralBNerf([this.limited.x, this.limited.y])
        this.limited.x := nerfedCoords[xComp], this.limited.y := nerfedCoords[yComp]
        return
    }

    dashTechniqueNerfSearch(dashZone, outOfDeadzone, aX, aY) {
        global currentTimeMS

        this.limited.pivotWasNerfed := false ; pivot hasn't been nerfed yet

        ; we nerf if the technique was completed in the near past
        this.limited.pivotNerfedCoords := getPivotNerfedCoords([aX, aY], outOfDeadzone
            , dashZone.pivotLockoutEntry)

        if this.limited.pivotNerfedCoords { ; if this is anything other than false (it is coordinates)
            this.limited.pivotWasNerfed := true
        }

        ; we take care not to get the same coordinates twice
        if !this.limited.pivotWasNerfed {
            ; get current dash zone info
            currentZone := getDashZoneOf(aX)
            if (currentZone == dashZone.saved.zone) {
                currentDashZoneInfo := dashZone.saved
            }
            else if IsObject(dashZone.queue[currentZone]) {
                currentDashZoneInfo := dashZone.queue[currentZone]
            }
            else {
                ; we need to detect if a new pivot was inputted
                currentDashZoneInfo := new dashZoneHistoryEntry(currentZone, currentTimeMS
                    , getPivotDid(dashZone.hist, currentZone, currentTimeMS))
            }

            this.limited.pivotNerfedCoords := getPivotNerfedCoords([aX, aY], outOfDeadzone
                , currentDashZoneInfo)
            if this.limited.pivotNerfedCoords { ; if this is anything other than false (it is coordinates)
                this.limited.pivotWasNerfed := true
            }
        }
        return
    }

    crouchTechniqueNerfSearch(crouchZone, aX, aY) {
        global currentTimeMS

        this.limited.uncrouchWasNerfed := false ; uncrouch hasn't been nerfed yet
        ; we nerf if the technique was completed in the near past
        this.limited.uncrouchNerfedCoords := getUncrouchNerfedCoords([aX, aY]
            , crouchZone.uncrouchLockoutEntry)

        if this.limited.uncrouchNerfedCoords { ; if this is anything other than false (it is coordinates)
            this.limited.uncrouchWasNerfed := true
        }

        ; we take care not to get the same coordinates twice
        if !this.limited.uncrouchWasNerfed {
            ; we get the current crouch zone info
            currentZone := getCrouchZoneOf(aY)
            if (currentZone == crouchZone.saved.zone) {
                currentCrouchZoneInfo := crouchZone.saved
            }
            else if IsObject(crouchZone.queue[currentZone]) {
                currentCrouchZoneInfo := crouchZone.queue[currentZone]
            }
            else {
                ; we need to detect if a new "uncrouch" was inputted
                currentCrouchZoneInfo := new crouchZoneHistoryEntry(currentZone, currentTimeMS
                    , getUncrouchDid(crouchZone.saved.zone, currentZone))
            }

            this.limited.uncrouchNerfedCoords := getUncrouchNerfedCoords([aX, aY]
                , currentCrouchZoneInfo)
            ; if this is anything other than false (it is coordinates)
            if this.limited.uncrouchNerfedCoords { 
                this.limited.uncrouchWasNerfed := true
            }
        }
        return
    }

    chooseLockout() {
        global xComp, global yComp
        ; function for solving conflicts between lockouts
        if this.limited.pivotWasNerfed {
            this.limited.x := this.limited.pivotNerfedCoords[xComp]
            this.limited.y := this.limited.pivotNerfedCoords[yComp]
        } else if this.limited.uncrouchWasNerfed {
            this.limited.x := this.limited.uncrouchNerfedCoords[xComp]
            this.limited.y := this.limited.uncrouchNerfedCoords[yComp]
        }
        return
    }

    horizontalRimFuzz() {
        this.limited.y := getFuzzyHorizontal100(this.limited.x, this.limited.y, this.hist[1].x, this.hist[1].y)
        return
    }
}