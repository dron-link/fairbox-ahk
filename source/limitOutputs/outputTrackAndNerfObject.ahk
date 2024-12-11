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

        ; we nerf if the technique was completed in the near past
        oldCondition := getPivotNerfCondition(aX, aY, outOfDeadzone, dashZone.pivotLockoutEntry)
        
        if oldCondition {
            this.limited.pivotNerfedCoords := getPivotNerfedCoords(oldCondition, [aX, aY])
            this.limited.pivotWasNerfed := oldCondition
        }
        else {
            /*  we scan for nerfs based on a saved, candidate or new dashzoneinfo
            */
            newCondition := getPivotNerfCondition(aX, aY, outOfDeadzone
            , getCurrentDashZoneInfo(dashZone.hist, dashZone.candidates, getDashZoneOf(aX)))
        
            this.limited.pivotWasNerfed := newCondition
            if newCondition {
                this.limited.pivotNerfedCoords := getPivotNerfedCoords(newCondition, [aX, aY])
            }
        }

        return
    }

    crouchTechniqueNerfSearch(crouchRange, aX, aY) {
        global currentTimeMS

        this.limited.uncrouchWasNerfed := false ; uncrouch hasn't been nerfed yet
        ; we nerf if the technique was completed in the near past
        this.limited.uncrouchNerfedCoords := getUncrouchNerfedCoords([aX, aY]
        , crouchRange.uncrouchLockoutEntry)

        if this.limited.uncrouchNerfedCoords { ; if this is anything other than false (it is coordinates)
            this.limited.uncrouchWasNerfed := true
        }

        ; we take care not to get the same coordinates twice
        if !this.limited.uncrouchWasNerfed {
            ; we get the current crouch zone info
            currentRangeIn := getIsInCrouchRange(aY)
            if (currentRangeIn == crouchRange.saved.in) {
                currentCrouchRangeInfo := crouchRange.saved
            }
            else if IsObject(crouchRange.candidate) {
                currentCrouchRangeInfo := crouchRange.candidate
            }
            else {
                ; we need to detect if a new "uncrouch" was inputted
                currentCrouchRangeInfo := new crouchRangeHistoryEntry(currentRangeIn, currentTimeMS
                , getUncrouchDid(crouchRange.saved.in, currentRangeIn))
            }

            this.limited.uncrouchNerfedCoords := getUncrouchNerfedCoords([aX, aY]
            , currentCrouchRangeInfo)
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