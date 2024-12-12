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

        ; search for nerf conditions based on the last saved technique completion info
        oldCondition := getPivotNerfCondition(aX, aY, outOfDeadzone, dashZone.pivotLockoutEntry)
        
        ; if there is oldCondition we assign it to pivotNerfCondition
        ; if there's not, we check for nerfs on the basis of completed techniques not yet saved
        this.limited.pivotNerfCondition := oldCondition 
        ? oldCondition : getPivotNerfCondition(aX, aY, outOfDeadzone
        , getCurrentDashZoneInfo(dashZone.hist, dashZone.candidates, getDashZoneOf(aX)))

        return
    }

    crouchTechniqueNerfSearch(crouchRange, aX, aY) {
        global currentTimeMS

        ; search for nerf conditions based on the last saved technique completion info
        oldCondition := getUncrouchNerfCondition(aX, aY, crouchRange.uncrouchLockoutEntry)

        ; if there is oldCondition we assign it to uncrouchNerfCondition
        ; if there's not, we check for nerfs on the basis of completed techniques not yet saved
        this.limited.uncrouchNerfCondition := oldCondition
        ? oldCondition : getUncrouchNerfCondition(aX, aY
        , getCurrentCrouchRangeInfo(crouchRange.saved, crouchRange.candidate, getIsInCrouchRange(aY)))
        
        return
    }

    applyLockout() {
        global xComp, global yComp
        
        ; choose one of the lockouts and apply it to the outputs
        if this.limited.pivotNerfCondition {
            nerfedCoords := getPivotNerfedCoords(this.limited.pivotNerfCondition
            , [this.limited.x, this.limited.y])
            this.limited.x := nerfedCoords[xComp], this.limited.y := nerfedCoords[yComp]
        } else if this.limited.uncrouchNerfCondition {
            nerfedCoords := getUncrouchNerfedCoords()
            this.limited.x := nerfedCoords[xComp], this.limited.y := nerfedCoords[yComp]
        }
        return
    }

    horizontalRimFuzz() {
        this.limited.y := getFuzzyHorizontal100(this.limited.x, this.limited.y, this.hist[1].x, this.hist[1].y)
        return
    }
}