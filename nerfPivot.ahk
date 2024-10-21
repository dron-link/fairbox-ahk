#Requires AutoHotkey v1.1

; https://stackoverflow.com/questions/45869823/how-do-i-create-a-class-in-autohotkey
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
    lastDelivered := new dashZoneHistoryEntry(false, -1000, true)
    
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

    zoneOf(aX, aY) {
        global ANALOG_DASH_LEFT
        global ANALOG_DASH_RIGHT
        global ZONE_CENTER
        global ZONE_L
        global ZONE_R
        if (aX <= ANALOG_DASH_LEFT) {
            return ZONE_L
        } else if (aX >= ANALOG_DASH_RIGHT) {
            return ZONE_R
        } else {
            return ZONE_CENTER
        }
    }
}

class pivotInfo {
    __New(did, timestamp) {
        this.did := did
        this.timestamp := timestamp
    }
}

class basePivot {
    string := "pivot"

    unsaved := new pivotInfo(false, -1000)
    queued := new pivotInfo(false, -1000)
    saved := new pivotInfo(false, -1000)

    wasNerfed := false
    nerfedCoords := ""

    jump2F := {force: false, timestamp: -1000}

    detect(aX, aY, dashZone) {
        return detectPivot(aX, aY, dashZone)   
    }

    generateNerfedCoords(aX, aY, techniqueInfoIn) {
        global ANALOG_STICK_MAX
        global FORCE_FTILT
        global ZONE_CENTER
        global ZONE_L
        global ZONE_R
        global TIMELIMIT_TAPSHUTOFF
        global TIMELIMIT_PIVOTTILT
        global TIMELIMIT_PIVOTTILT_YDASH
        global xComp
        global yComp
        global currentTimeMS
        global upY
        global upYTimestamp
        global downY
        global downYTimestamp
        this.nerfedCoords := ""
        doTrimCoordinate := false

        if ((aX != 0 or aY != 0) and currentTimeMS - techniqueInfoIn.timestamp < TIMELIMIT_PIVOTTILT) {
            maxDistanceFactor := 1.1 * ANALOG_STICK_MAX / sqrt(aX**2 + aY**2) ; 1.1 ensures shoot beyond circle

            /*  if upY and the player has not shut off tap jump WITH actions done before completing 
                the pivot (such as upY dashes and downY dashes)
            */
            if (upY and (currentTimeMS - upYTimestamp < TIMELIMIT_TAPSHUTOFF or upYTimestamp >= techniqueInfoIn.timestamp)) {
                this.wasNerfed := true
                if (Abs(aX) > aY) {
                    /*  //Force all upward angles to a minimum of 45deg away from the horizontal
                        //to prevent pivot uftilt and ensure tap jump
                    */
                    this.nerfedCoords := trimToCircle(aX > 0 ? 90 : -90, 90) ; either 90, 90 or -90, 90. 90 = 127 cos 45deg
                } else {
                    this.nerfedCoords := trimToCircle(aX * maxDistanceFactor, aY * maxDistanceFactor)
                }                
            } 
            ; if the player hasn't shut off tap downsmash
            else if (downY and currentTimeMS - downYTimestamp < TIMELIMIT_TAPSHUTOFF) {
                this.wasNerfed := true
                this.nerfedCoords := trimToCircle(aX * maxDistanceFactor, aY * maxDistanceFactor)
            }
            ; if the player shut off the tap-jump or tap upsmash, by pivoting with upY dashes
            else if (upY and upYTimestamp < techniqueInfoIn.timestamp
                and currentTimeMS - techniqueInfoIn.timestamp < TIMELIMIT_PIVOTTILT_YDASH) {
                this.wasNerfed := true
                /*  if P_RIGHTLEFT then negative X
                    if P_LEFTRIGHT then positive X
                    apparently CarVac uses the opposite x directions for the ftilt.
                    what does the proposal team mean when saying pressing A too early as a failure state?
                */
                this.nerfedCoords := [P_RIGHTLEFT ? -FORCE_FTILT : FORCE_FTILT     , FORCE_FTILT]
            } 
            ; if the player shut off tap downsmash, by pivoting with downY dashes
            else if (downY and downYTimestamp < techniqueInfoIn.timestamp
                and currentTimeMS - techniqueInfoIn.timestamp < TIMELIMIT_PIVOTTILT_YDASH) {
                this.wasNerfed := true
                this.nerfedCoords := [P_RIGHTLEFT ? -FORCE_FTILT : FORCE_FTILT     , -FORCE_FTILT]
            }
        }
        return
    } ; end of pivot.generateNerfedCoords()
}

detectPivot(aX, aY, dashZone) {
    global P_RIGHTLEFT
    global P_LEFTRIGHT
    global ZONE_CENTER
    global ZONE_L
    global ZONE_R
    global TIMELIMIT_HALFFRAME
    global TIMELIMIT_FRAME
    global currentTimeMS

    result := False
    pivotDebug := false ; if you want to enable detectPivot() testing, set this true
    pivotDiscarded := -1 ; for testing. -1 to avoid all switch-cases
    /*  ignoring timing, has the player inputted the correct sequence?
        empty pivot inputs:
        --- past --> currentDashZone
        3---2---1---aX        means:      notes:
            R   L   N       p rightleft
        R   -   L   N       p rightleft   (it's R N L N because there can't be R R or L L in history)
            L   R   N       p leftright
        L   -   R   N       p leftright   (L N R N)
        (in this comment, N means center)
    */
    if (dashZone.zoneOf(aX, aY) == ZONE_CENTER) {
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
        pivotLength := currentTimeMS - dashZone.hist[1].timestamp ; ms, computes latest dash duration
        ; //check for staleness (meaning that some inputs are too old for this to be a successful pivot)
        if dashZone.hist[2].stale {
            result := false
            if !pivotDiscarded {
                pivotDiscarded := 1
            }
        ; true if the following sequence is stale:  aX center  1 oppositeCardinal  2 center  3 cardinal
        } else if (dashZone.hist[2].zone == ZONE_CENTER and dashZone.hist[3].stale) { 
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
        pivotLiveDebugMessages(result, pivotDiscarded)
    }

    return result ; returns whether there was no pivot, or the direction of the pivot if there was
}

pivotLiveDebugMessages(result, pivotDiscarded) {
    Switch pivotDiscarded 
    {
    Case false:
        if (result == P_LEFTRIGHT) {
            OutputDebug, % "P_LEFTRIGHT`n"
        } else if (result == P_RIGHTLEFT) {
            OutputDebug, % "P_RIGHTLEFT`n"
        }
    Case 1:
        OutputDebug, % "check #1 stale, no pivot`n"
    Case 2:
        OutputDebug, % "check #2 length, no pivot`n"
    }
    return
}

savePivotHistory(ByRef dashZone, ByRef pivot, latestMultipressBeginningTimestamp) {
    global TIMELIMIT_SIMULTANEOUS
    global TIMESTALE_PIVOT_INPUTSEQUENCE
    global currentTimeMS

    ; set lingering pivot as false
    if pivot.saved.did {
        pivot.saved.did := currentTimeMS - uncrouch.saved.timestamp < 1000 ? pivot.saved.did : false 
    }

    /*  we need to see if enough time has passed for the input to not be
        part of a multiple key single input, and that it is different
        from the last entry and because of that we need a new entry
    */
    if (currentTimeMS - latestMultipressBeginningTimestamp >= TIMELIMIT_SIMULTANEOUS) {
        if (dashZone.lastDelivered.zone != dashZone.saved.zone) {
            dashZone.hist.Pop(), dashZone.hist.InsertAt(1, dashZone.lastDelivered)
        } 
        if pivot.unsaved.did {
            pivot.saved := new pivotInfo(pivot.unsaved.did, pivot.unsaved.timestamp)
            pivot.unsaved.did := false, pivot.queued.did := false
        }
    }

    ; check if a dash entry (and subsequent ones) are stale, and flag them
    Loop, % dashZone.historyLength {
        if (currentTimeMS - dashZone.hist[A_Index].timestamp > TIMESTALE_PIVOT_INPUTSEQUENCE) {
            staleIndex := A_Index ; found entry that has to be stale
            while (staleIndex <= dashZone.historyLength) {
                dashZone.hist[staleIndex].stale := true
                staleIndex += 1
            }
            break
        }
    }

    return
}

storePivotsBeforeMultipressEnds(output, ByRef dashZone, ByRef pivot) {
    global currentTimeMS
    ; handles the case of nerfing the "neutral" of a pivot into a dash, so it damages the successful pivot input
    pivot.unsaved.did := pivot.detect(output.limited.x, output.limited.y, dashZone)
    ; stores the first pivot detected within the multipress window
    if (pivot.unsaved.did and !pivot.queued.did) {
        ; new object so that modifying unsaved.did doesn't modify queued.did
        pivot.queued.did := new pivotInfo(pivot.unsaved.did, pivot.unsaved.timestamp)
    }   
    
    dashZoneOfOutput := dashZone.zoneOf(output.limited.x, output.limited.y, dashZone)
    if (dashZone.lastDelivered.zone != dashZoneOfOutput) {
        dashZone.lastDelivered := new dashZoneHistoryEntry(dashZoneOfOutput, currentTimeMS, false)
    }
    return
}
