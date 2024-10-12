#Requires AutoHotkey v1.1

; https://stackoverflow.com/questions/45869823/how-do-i-create-a-class-in-autohotkey
class dashZoneHistoryEntry {
    __New(zone, timestamp, stale) {
        this.zone := zone
        this.timestamp := timestamp
        this.stale := stale
    }
}

dashZoneHist := []
Loop, % DASH_HISTORY_LENGTH {
    dashZoneHist.Push(new dashZoneHistoryEntry(NOT_DASH, 0, true))
}

class dashZoneObjectTemplate {
    string := "dashZone"
    lastDelivered := new dashZoneHistoryEntry(false, 0, true)
    saved := new dashZoneHistoryEntry(false, 0, true)
    oldestQueueTimestamp := -1000

    zoneOf(aX, aY) {
        global ANALOG_DASH_LEFT
        global ANALOG_DASH_RIGHT
        global NOT_DASH
        global ZONE_L
        global ZONE_R
        if (aX <= ANALOG_DASH_LEFT) {
            return ZONE_L
        } else if (aX >= ANALOG_DASH_RIGHT) {
            return ZONE_R
        } else {
            return NOT_DASH
        }
    }
}

class pivotInfo {
    __New(did, timestamp) {
        this.did := did
        this.timestamp := timestamp
    }
}

class pivotObjectTemplate {
    string:="pivot"

    fromDetector := new pivotInfo(false, -1000)
    queued := new pivotInfo(false, -1000)
    saved := new pivotInfo(false, -1000)

    wasLookedFor := false
    nerfWasCalc := false
    nerfedCoords := [0, 0]
    jump2F := {force: false, timestamp: -1000}

    detect(aX, aY, dashZone) {
        global P_RIGHTLEFT
        global P_LEFTRIGHT
        global dashZoneHist
        global NOT_DASH
        global ZONE_L
        global ZONE_R
        global currentTimeMS
        global TIMELIMIT_HALFFRAME
        global TIMELIMIT_FRAME

        result := False
        pivotDebug := false ; if you want to enable detectPivot() testing, set this true
        pivotDiscarded := -1 ; for testing
        detectorDashZone := dashZone.zoneOf(aX, aY)
        /* ; ignoring timing, has the player inputted the correct sequence?
            pivot inputs:
            --- past --- current
            3---2---1---aX        means:      notes:
                R   L   N       p rightleft
            R   -   L   N       p rightleft   (it's R N L N because there can't be R R or L L)
                L   R   N       p leftright
            L   -   R   N       p leftright   (L N R N)
        */
        if (detectorDashZone == NOT_DASH) {
            if (dashZoneHist[1].zone == ZONE_L and (dashZoneHist[2].zone == ZONE_R or dashZoneHist[3].zone == ZONE_R)) {
                result := P_RIGHTLEFT
                pivotDiscarded := false
            }
            else if (dashZoneHist[1].zone == ZONE_R and (dashZoneHist[2].zone == ZONE_L or dashZoneHist[3].zone == ZONE_L)) {
                result := P_LEFTRIGHT
                pivotDiscarded := false
            }
        }

        if result { ; this is the code block for discarding pivot attempts

            pivotLength := currentTimeMS - dashZoneHist[1].timestamp ; ms, stores latest dash duration

            ; //check for staleness (meaning that some inputs are too old for this to be a successful pivot)
            if dashZoneHist[2].stale {
                result := false
                if !pivotDiscarded {
                    pivotDiscarded := 1
                }
            } else if (dashZoneHist[2].zone == NOT_DASH and dashZoneHist[3].stale) { ; aX neutral  1 opposite  2 neutral  3 cardinal
                result := false
                if !pivotDiscarded {
                    pivotDiscarded := 1
                }

                /*
                    has the player only held the latest dash for around 1
                    frame in duration? that's necessary for pivoting
                */
            } else if (pivotLength < TIMELIMIT_HALFFRAME or pivotLength > TIMELIMIT_FRAME + TIMELIMIT_HALFFRAME) {
                ; //less than 50% chance it was a successful pivot
                result := false
                if !pivotDiscarded {
                    pivotDiscarded := 2
                }
            }
        } ; end of block for discarding pivot attempts

        if pivotDebug {
            Switch pivotDiscarded {
            Case false:
                if (result == P_LEFTRIGHT) {
                    Msgbox P_LEFTRIGHT
                } else if (result == P_RIGHTLEFT) {
                    Msgbox P_RIGHTLEFT
                }
            Case 1:
                Msgbox stage 1 stale, no pivot
            Case 2:
                Msgbox stage 2 length, no pivot
            }
        }

        return result ; returns whether there was no pivot, or the direction of the pivot if there was
    }

    nerf(aX, aY, bufferStage) {
        global xComp
        global yComp
        global dashZoneHist
        global NOT_DASH
        global ZONE_L
        global ZONE_R
        global currentTimeMS
        global ANALOG_STICK_MAX
        global upY
        global upYTimestamp
        global downY
        global downYTimestamp
        global TIMELIMIT_TAPSHUTOFF
        global TIMELIMIT_PIVOTTILT_YDASH
        global FORCE_FTILT

        this.nerfWasCalc := true
        resultCoords := [aX, aY]

        doTrimCoordinate := false
        if (aX != 0 or aY != 0) {
            unityDistanceFactor := 1.1 * (ANALOG_STICK_MAX) / sqrt(aX**2 + aY**2) ; 1.1 ensures shoot beyond circle

            ; if upY and the player has not shut off tap jump WITH actions done before completing the pivot (such as upY dashes)
            if (upY and (currentTimeMS - upYTimestamp < TIMELIMIT_TAPSHUTOFF or upYTimestamp >= this[bufferStage].timestamp)
                and not this.jump2F.force) {
                this.jump2F.force := false ; change to true to activate CarVac HayBox style timed nerf
                this.jump2F.timestamp := currentTimeMS

                if (Abs(aX) > aY) { ; //Force all upward angles to a minimum of 45deg away from the horizontal
                    ; //to prevent pivot uftilt and ensure tap jump
                    if (aX > 0) {
                        resultCoords[xComp] := 90 ; = 127 cos 45deg
                    } else if (aX < 0) {
                        resultCoords[xComp] := -90
                    }
                    resultCoords[yComp] := 90 ; 127 sin 45deg
                    doTrimCoordinate := true

                } else {
                    resultCoords[xComp] := aX * unityDistanceFactor
                    resultCoords[yComp] := aY * unityDistanceFactor
                    doTrimCoordinate := true
                }

                ; if the player hasn't shut off tap downsmash
            } else if (downY and currentTimeMS - downYTimestamp < TIMELIMIT_TAPSHUTOFF) {

                resultCoords[xComp] := aX * unityDistanceFactor
                resultCoords[yComp] := aY * unityDistanceFactor
                doTrimCoordinate := true

                ; if the player shut off the tap-jump or tap upsmash, by pivoting with upY dashes
            } else if (upY and upYTimestamp < this[bufferStage].timestamp
                and currentTimeMS - this[bufferStage].timestamp < TIMELIMIT_PIVOTTILT_YDASH and not this.jump2F.force) {

                if (this[bufferStage].did == P_RIGHTLEFT) {
                    resultCoords[xComp] := - FORCE_FTILT ; apparently CarVac uses the opposite x directions for the ftilt.
                } else if (this[bufferStage].did == P_LEFTRIGHT) { ; what does the proposal team mean when saying pressing A too early?
                    resultCoords[xComp] := FORCE_FTILT
                }
                resultCoords[yComp] := FORCE_FTILT

                ; if the player shut off tap downsmash, by pivoting with downY dashes
            } else if (downY and downYTimestamp < this[bufferStage].timestamp
                and currentTimeMS - this[bufferStage].timestamp < TIMELIMIT_PIVOTTILT_YDASH) {
                if (this[bufferStage].did == P_RIGHTLEFT) {
                    resultCoords[xComp] := - FORCE_FTILT
                } else if (this[bufferStage].did == P_LEFTRIGHT) {
                    resultCoords[xComp] := FORCE_FTILT
                }
                resultCoords[yComp] := - FORCE_FTILT
            }
        }

        if doTrimCoordinate {
            return trimToCircle(resultCoords[xComp], resultCoords[yComp])
        } else {
            return resultCoords
        }
    }
}

savePivotHistory(ByRef dashZone, ByRef pivot) {
    global currentTimeMS
    global TIMELIMIT_SIMULTANEOUS
    global dashZoneHist
    global DASH_HISTORY_LENGTH
    global TIMESTALE_PIVOT_INPUTSEQUENCE

    /*
        we need to see if enough time has passed for the input to not be
        part of a multiple key single input, and that it is different
        from the last entry and because of that we need a new entry
    */
    if (currentTimeMS - dashZone.oldestQueueTimestamp >= TIMELIMIT_SIMULTANEOUS) {
        if (dashZone.lastDelivered.zone != dashZoneHist[1].zone) {
            dashZoneHist.Pop()
            dashZoneHist.InsertAt(1, dashZone.lastDelivered)
        }
        ; if there's an queued pivot and the window for simultaneous inputs expired...
        if pivot.queued.did {
            pivot.saved := pivot.queued
            ; .saved will deal with the nerf instance from now on - technique queue has to be cleaned
            pivot.queued := new pivotInfo(false, 0)
        }
        
    }

    ; check if a dash entry (and subsequent ones) are stale, and flag them
    Loop, % DASH_HISTORY_LENGTH {
        if (currentTimeMS - dashZoneHist[A_Index].timestamp > TIMESTALE_PIVOT_INPUTSEQUENCE) {
            staleIndex := A_Index ; found entry that has to be stale
            while (staleIndex <= DASH_HISTORY_LENGTH) {
                dashZoneHist[staleIndex].stale := true
                staleIndex += 1
            }
            break
        }
    }
    ; now that entries have been checked for staleness, we set this object equivalence
    dashZone.saved := dashZoneHist[1]

    return
}

rememberDashZonesNotSaved(aX, ByRef dashZone) {
    global currentTimeMS
    global TIMELIMIT_SIMULTANEOUS
    global analogHistory
    global FINAL_DASHZONE

    ; if the dashzone that will sent to the game is different from the previous, then we record
    if (dashZone.zoneOf(aX, "") != dashZone.lastDelivered.zone) {
        dashZone.lastDelivered := new dashZoneHistoryEntry(dashZone.zoneOf(aX, ""), currentTimeMS, false)

        ; we need to see if the current input actually represents a new dash zone (either from a lone input or
        ; as the FIRST keystroke of a group of simultaneous keystrokes) in order to assign a timestamp to it
        if (currentTimeMS - dashZone.oldestQueueTimestamp >= TIMELIMIT_SIMULTANEOUS) {
            dashZone.oldestQueueTimestamp := currentTimeMS
            analogHistory[1].simultaneousFinish |= FINAL_DASHZONE
        }
    }

    return
}
