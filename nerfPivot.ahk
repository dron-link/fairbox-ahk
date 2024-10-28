#Requires AutoHotkey v1.1

; https://stackoverflow.com/questions/45869823/how-do-i-create-a-class-in-autohotkey ; taught me how to __New()
class dashZoneHistoryEntry {
    __New(zone, timestamp, stale) {
        this.zone := zone
        this.timestamp := timestamp
        this.stale := stale
    }
}

class baseDashZone {
    static historyLength := 5 ; MINIMUM 3

    string := "dashZone"

    unsaved := new dashZoneHistoryEntry(false, -1000, true)
    queue := {}
    saved[]
    {
        get {
            return this.hist[1]
        }
    }

    __New() { ; generates dashZone.hist
        this.hist := []
        Loop, % this.historyLength {
            this.hist.Push(new dashZoneHistoryEntry(false, -1000, true))
        }
    }

    saveHistory() {
        if (this.unsaved != this.saved) { ; we avoid inserting the same object consecutively
            this.hist.Pop(), this.hist.InsertAt(1, this.unsaved)
        }
        this.queue := {}
        return
    }

    checkHistoryEntryStaleness() {
        global TIMESTALE_PIVOT_INPUTSEQUENCE, global currentTimeMS
        ; check if a dash entry (and subsequent ones) are stale, and flag them
        Loop, % this.historyLength {
            if (currentTimeMS - this.hist[A_Index].timestamp > TIMESTALE_PIVOT_INPUTSEQUENCE) {
                staleIndex := A_Index ; found entry that has to be stale
                while (staleIndex <= this.historyLength) {
                    this.hist[staleIndex].stale := true,    staleIndex += 1
                }
                break
            }
        }
    }

    zoneOf(aX, aY) {
        return getDashZoneOf(aX, aY)

    }

    getCurrentInfo(aX, aY) { ; this method goes uncalled as far as i know. i added it for completeness
        return getCurrentDashZoneInfo(aX, aY, this)
    }

    storeInfoBeforeMultipressEnds(aX, aY) {
        return storeDashZoneInfoBeforeMultipressEnds(aX, aY, this)
    }
}

getDashZoneOf(aX, aY) {
    global ANALOG_DASH_LEFT, global ANALOG_DASH_RIGHT, global ZONE_CENTER, global ZONE_L, global ZONE_R
    if (aX <= ANALOG_DASH_LEFT) {
        return ZONE_L
    } else if (aX >= ANALOG_DASH_RIGHT) {
        return ZONE_R
    } else {
        return ZONE_CENTER
    }
}

getCurrentDashZoneInfo(aX, aY, dashZone) {
    global currentTimeMS

    currentZone := getDashZoneOf(aX, aY)

    if (currentZone == dashZone.saved.zone) {
        return dashZone.saved
    } else if IsObject(dashZone.queue[currentZone]) {
        return dashZone.queue[currentZone]
    } else {
        return new dashZoneHistoryEntry(currentZone, currentTimeMS, false)
    }
}

storeDashZoneInfoBeforeMultipressEnds(aX, aY, ByRef dashZone) {
    global currentTimeMS
    dashZoneOfOutput := getDashZoneOf(aX, aY)
    if (dashZoneOfOutput == dashZone.saved.zone) {
        dashZone.unsaved := dashZone.saved
    } else {
        if !IsObject(dashZone.queue[dashZoneOfOutput]) {
            dashZone.queue[dashZoneOfOutput] := new dashZoneHistoryEntry(dashZoneOfOutput, currentTimeMS, false)
        }
        dashZone.unsaved := dashZone.queue[dashZoneOfOutput]
    }
    return
}

class pivotInfo extends techniqueClassThatHasTimingLockouts {
}

class basePivot {
    string := "pivot"

    unsaved := new pivotInfo(false, -1000)
    queue := {}
    saved := new pivotInfo(false, -1000)
    lockout := new pivotInfo(false, -1000)

    wasNerfed := false
    nerfedCoords := ""

    saveHistory() {
        if (this.unsaved.did and this.unsaved.did != this.saved.did) {
            this.lockout := this.unsaved
        }
        this.saved := this.unsaved
        this.queue := {}
    }

    lockoutExpiryCheck() {
        global TIMELIMIT_PIVOTTILT, global currentTimeMS
        if (this.lockout.did and currentTimeMS - this.lockout.timestamp >= TIMELIMIT_PIVOTTILT) {
            this.lockout := new pivotInfo(false, currentTimeMS)
        }
        return
    }

    detect(aX, aY, dashZone) {
        return detectPivot(aX, aY, dashZone)
    }
    nerfSearch(aX, aY, dashZone) {
        return nerfBasedOnHistory(aX, aY, dashZone, pivotInfo, this)
    }
    generateNerfedCoords(aX, aY, pivotInstance) {
        this.nerfedCoords := getPivotLockoutNerfedCoords(aX, aY, pivotInstance, this)
        return
    }
    getCurrentInfo(aX, aY, dashZone) {
        return getCurrentPivotInfo(aX, aY, detectPivot(aX, aY, dashZone), this)
    }
    storeInfoBeforeMultipressEnds(aX, aY, dashZone) {
        return storePivotsBeforeMultipressEnds(aX, aY, detectPivot(aX, aY, dashZone), this)
    }
}

detectPivot(aX, aY, dashZone) {
    global P_RIGHTLEFT, global P_LEFTRIGHT, global ZONE_CENTER, global ZONE_L, global ZONE_R
    global TIMELIMIT_HALFFRAME, global TIMELIMIT_FRAME

    result := False
    pivotDebug := false ; if you want to test detectPivot() live, set this true
    pivotDiscarded := -1 ; for testing. -1 to avoid all switch-cases
    currentDashZone := getCurrentDashZoneInfo(aX, aY, dashZone)
    /*  ignoring timing, has the player inputted the correct sequence?
        empty pivot inputs:
        --- past --> current
        3---2---1---aX        means:      notes:
            R   L   N       p rightleft
        R   -   L   N       p rightleft   (it's R N L N because there can't be R R or L L in history)
            L   R   N       p leftright
        L   -   R   N       p leftright   (L N R N)
        (in this comment, N means center)
    */
    if (currentDashZone.zone == ZONE_CENTER) {
        if (dashZone.hist[1].zone == ZONE_L and (dashZone.hist[2].zone == ZONE_R or dashZone.hist[3].zone == ZONE_R)) {
            result := P_RIGHTLEFT
            pivotDiscarded := false
        }
        else if (dashZone.hist[1].zone == ZONE_R and (dashZone.hist[2].zone == ZONE_L or dashZone.hist[3].zone == ZONE_L)) {
            result := P_LEFTRIGHT
            pivotDiscarded := false
        }
    }

    if result { ; this is the code block for discarding pivot attempts
        pivotLength := currentDashZone.timestamp - dashZone.hist[1].timestamp ; ms, computes latest dash duration
        ; //check for staleness (meaning that some inputs are too old for this to be a successful pivot)
        if dashZone.hist[2].stale {
            result := false
            if !pivotDiscarded {
                pivotDiscarded := 1
            }
        }
        ; true if the following sequence is stale:  aX center  1 oppositeCardinal  2 center  3 cardinal
        else if (dashZone.hist[2].zone == ZONE_CENTER and dashZone.hist[3].stale) {
            result := false
            if !pivotDiscarded {
                pivotDiscarded := 1
            }
        }
        /*  has the player only held the latest dash for around 1
            frame in duration? that's necessary for pivoting
        */
        else if (pivotLength < TIMELIMIT_HALFFRAME or pivotLength > TIMELIMIT_FRAME + TIMELIMIT_HALFFRAME) {
            ; //less than 50% chance it was a successful pivot
            result := false
            if !pivotDiscarded {
                pivotDiscarded := 2
            }
        }
    } ; end of block for discarding pivot attempts
    
    if pivotDebug {
        pivotLiveDebugMessages(result, pivotDiscarded) ; over at testingTools.ahk
    }

    return result ; returns whether there was no pivot, or the direction of the pivot if there was
}

getPivotLockoutNerfedCoords(aX, aY, pivotInstance, ByRef pivot) {
    global ANALOG_STICK_MAX, global FORCE_FTILT, global ZONE_CENTER, global ZONE_L, global ZONE_R
    global TIMELIMIT_TAPSHUTOFF, global TIMELIMIT_PIVOTTILT, global TIMELIMIT_PIVOTTILT_YDASH
    global P_RIGHTLEFT, global P_LEFTRIGHT, global xComp, global yComp, global currentTimeMS

    upYDeadzone := getCurrentOutOfDeadzoneInfo(aY, pivot.outOfDeadzone.up)
    downYDeadzone := getCurrentOutOfDeadzoneInfo(aY, pivot.outOfDeadzone.down)
    doTrimCoordinate := false

    if ((aX != 0 or aY != 0) and currentTimeMS - pivotInstance.timestamp < TIMELIMIT_PIVOTTILT) {
        maxDistanceFactor := 1.1 * ANALOG_STICK_MAX / sqrt(aX**2 + aY**2) ; 1.1 ensures shoot beyond circle

        /*  if upYDeadzone.out and the player has not shut off tap jump WITH actions done before completing
            the pivot (such as upY dashes and downY dashes)
        */
        if (upYDeadzone.out and (currentTimeMS - upYDeadzone.timestamp < TIMELIMIT_TAPSHUTOFF or upYDeadzone.timestamp >= pivotInstance.timestamp)) {
            pivot.wasNerfed := true
            if (Abs(aX) > aY) {
                /*  //Force all upward angles to a minimum of 45deg away from the horizontal
                    //to prevent pivot uftilt and ensure tap jump
                */
                return trimToCircle(aX > 0 ? 90 : -90, 90) ; params [90, 90] or [-90, 90]. is radius=127
            } else {
                return trimToCircle(aX * maxDistanceFactor, aY * maxDistanceFactor)
            }
        }
        ; if the player hasn't shut off tap downsmash
        else if (downYDeadzone.out and currentTimeMS - downYDeadzone.timestamp < TIMELIMIT_TAPSHUTOFF) {
            pivot.wasNerfed := true
            return trimToCircle(aX * maxDistanceFactor, aY * maxDistanceFactor)
        }
        ; if the player shut off the tap-jump or tap upsmash, by pivoting with upY dashes
        else if (upYDeadzone.out and upYDeadzone.timestamp < pivotInstance.timestamp
            and currentTimeMS - pivotInstance.timestamp < TIMELIMIT_PIVOTTILT_YDASH) {
            pivot.wasNerfed := true
            /*  if P_RIGHTLEFT then negative X
                if P_LEFTRIGHT then positive X
                apparently CarVac uses the opposite x directions for the ftilt.
                what does the proposal team mean when saying pressing A too early as a failure state?
            */
            return [pivotInstance.did == P_RIGHTLEFT ? -FORCE_FTILT : FORCE_FTILT, FORCE_FTILT]
        }
        ; if the player shut off tap downsmash, by pivoting with downY dashes
        else if (downYDeadzone.out and downYDeadzone.timestamp < pivotInstance.timestamp
            and currentTimeMS - pivotInstance.timestamp < TIMELIMIT_PIVOTTILT_YDASH) {
            pivot.wasNerfed := true
            return [pivotInstance.did == P_RIGHTLEFT ? -FORCE_FTILT : FORCE_FTILT     , -FORCE_FTILT]
        }
    }
    return
}

getCurrentPivotInfo(aX, aY, didPivotNow, pivot) {
    global currentTimeMS

    if (didPivotNow == pivot.saved.did) {
        return pivot.saved
    } else if IsObject(pivot.queue[didPivotNow]) {
        return pivot.queue[didPivotNow] 
    } else {
        return new pivotInfo(didPivotNow, currentTimeMS)
    }

}

storePivotsBeforeMultipressEnds(aX, aY, outputDidPivot, ByRef pivot) {
    global currentTimeMS

    if (outputDidPivot == pivot.saved.did) {
        pivot.unsaved.did := pivot.saved.did
    } else {
        if !IsObject(pivot.queue[outputDidPivot]) {
            pivot.queue[outputDidPivot] := new pivotInfo(outputDidPivot, currentTimeMS)
        }
        pivot.unsaved := pivot.queue[outputDidPivot]
    }

    return
}
