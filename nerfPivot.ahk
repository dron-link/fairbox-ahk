#Requires AutoHotkey v1.1

dashZoneOf(aX) { ;
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

detectPivot(aX) {
    global

    result := P_NONE
    pivotDebug := false ; if you want to enable detectPivot() testing, set this true
    pivotDiscarded := -1 ; for testing
    detectorDashZone := dashZoneOf(aX)
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

    /*
    debugMessage := detectorDashZone . "-"
    Loop, % DASH_HISTORY_LENGTH {
      debugMessage .= dashZoneHist[A_Index].zone . "-"
    }
    Msgbox % debugMessage
    */

    if (result != P_NONE) { ; this is the code block for discarding pivot attempts

        pivotLength := currentTimeMS - dashZoneHist[1].timestamp ; ms, stores latest dash duration

        ; //check for staleness (meaning that some inputs are too old for this to be a successful pivot)
        if dashZoneHist[2].stale {
            result := P_NONE
            if !pivotDiscarded {
                pivotDiscarded := 1
            }
        } else if (dashZoneHist[2].zone == NOT_DASH and dashZoneHist[3].stale) { ; aX neutral  1 opposite  2 neutral  3 cardinal
            result := P_NONE
            if !pivotDiscarded {
                pivotDiscarded := 1
            }

            ; has the player only held the latest dash for around 1 frame in duration? that's necessary for pivoting
        } else if (pivotLength < TIMELIMIT_HALFFRAME or pivotLength > TIMELIMIT_FRAME + TIMELIMIT_HALFFRAME) {
            ; //less than 50% chance it was a successful pivot
            result := P_NONE
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
            Msgbox stage 1 stale p_none
        Case 2:
            Msgbox stage 2 length p_none
        }
    }

    return result
}

pivotNerf(aX, aY, pivotDirectionIn, pivotTimestampIn) {
    global

    preliminary := [aX, aY]

    nerfedPivotWasCalc := true ; true when pivotNerf() runs
    doTrimCoordinate := true
    if (aX != 0 or aY != 0) {
        unityDistanceFactor := 1.1 * (ANALOG_STICK_MAX) / sqrt(aX**2 + aY**2)
        /*
            if upY and the player has not shut off tap jump with actions done before completing the pivot (such as angled dash)
            and tap jump hasn't been forced already for this pivot
              force tap jump
            if downY and tap-down can be done
              carry to rim
            if the player has shut off tap jump with actions done before completing the pivot
            and tap jump hasn't been forced already for this pivot
              force f-tilt
            if the player has shut off tap down with actions done before completing the pivot
              force f-tilt
        */

        ; if upY and the player has not shut off tap jump WITH actions done before completing the pivot (such as upY dashes)
        if (upY and (currentTimeMS - upYTimestamp < TIMELIMIT_TAPSHUTOFF or upYTimestamp >= pivotTimestampIn)
            and not pivot2FJump.force) {
            pivot2FJump.force := false ; change to true to activate CarVac HayBox style timed nerf
            pivot2FJump.timestamp := currentTimeMS

            if (Abs(aX) > aY) { ; //Force all upward angles to a minimum of 45deg away from the horizontal
                ; //to prevent pivot uftilt and ensure tap jump
                if (aX > 0) {
                    preliminary[xComp] := 90 ; = 127 cos 45deg
                } else if (aX < 0) {
                    preliminary[xComp] := -90
                }
                preliminary[yComp] := 90 ; 127 sin 45deg

            } else {
                preliminary[xComp] := aX * unityDistanceFactor
                preliminary[yComp] := aY * unityDistanceFactor
            }

            ; if the player hasn't shut off tap downsmash
        } else if (downY and currentTimeMS - downYTimestamp < TIMELIMIT_TAPSHUTOFF) {

            preliminary[xComp] := aX * unityDistanceFactor
            preliminary[yComp] := aY * unityDistanceFactor

            ; if the player shut off the tap-jump or tap upsmash, by pivoting with upY dashes
        } else if (upY and upYTimestamp < pivotTimestampIn
            and currentTimeMS - pivotTimestampIn < TIMELIMIT_PIVOTTILT_YDASH and not pivot2FJump.force) {

            if (pivotDirectionIn == P_RIGHTLEFT) {
                preliminary[xComp] := - FORCE_FTILT ; apparently CarVac uses the opposite x directions for the ftilt.
            } else if (pivotDirectionIn == P_LEFTRIGHT) { ; what does the proposal team mean when saying pressing A too early?
                preliminary[xComp] := FORCE_FTILT
            }
            preliminary[yComp] := FORCE_FTILT
            doTrimCoordinate := false

            ; if the player shut off tap downsmash, by pivoting with downY dashes
        } else if (downY and downYTimestamp < pivotTimestampIn
            and currentTimeMS - pivotTimestampIn < TIMELIMIT_PIVOTTILT_YDASH) {
            if (pivotDirectionIn == P_RIGHTLEFT) {
                preliminary[xComp] := - FORCE_FTILT
            } else if (pivotDirectionIn == P_LEFTRIGHT) {
                preliminary[xComp] := FORCE_FTILT
            }
            preliminary[yComp] := - FORCE_FTILT
            doTrimCoordinate := false
        } else {
            doTrimCoordinate := false
        }
    }

    if doTrimCoordinate {
        result := trimToCircle(preliminary[xComp], preliminary[yComp])
        return result
    } else {
        return preliminary
    }
}


updateDashZoneHistory() {
    global

    /* we need to see if enough time has passed for the input to not be part of a multiple key single input. and that it is different
    from the last entry and so we need a new entry
    */
    if (currentTimeMS - oldestUnsavedDashZoneTimestamp >= TIMELIMIT_SIMULTANEOUS
        and dashZoneHist[1].zone != dashZone.unsaved.zone) {

        newDashZoneHistoryEntry := new dashZoneHistoryEntry
        newDashZoneHistoryEntry.timestamp := dashZone.unsaved.timestamp
        newDashZoneHistoryEntry.stale := false
        newDashZoneHistoryEntry.zone := dashZone.unsaved.zone

        dashZoneHist.Pop(), dashZoneHist.InsertAt(1, newDashZoneHistoryEntry)
    }

    return
}

makeDashZoneStale() {
    global
    ; check if a dash entry (and subsequent ones) are stale, and flag them
    Loop, % DASH_HISTORY_LENGTH {
        if ((currentTimeMS - dashZoneHist[A_Index].timestamp) > (TIMESTALE_PIVOT_INPUTSEQUENCE)) {
            staleIndex := A_Index ; found stale entry
            while (staleIndex <= DASH_HISTORY_LENGTH) {
                dashZoneHist[staleIndex].stale := true
                staleIndex += 1
            }
            break
        }
    }

    return
}

savePivotHistory() {
    global

    updateDashZoneHistory()
    makeDashZoneStale()

    ; if there's an unsaved direction and the window for simultaneous inputs expired...
    if (pivot.unsaved.did != P_NONE and currentTimeMS - oldestUnsavedDashZoneTimestamp >= TIMELIMIT_SIMULTANEOUS) {
        pivot.saved.did := pivot.unsaved.did
        pivot.saved.timestamp := pivot.unsaved.timestamp
        ; .saved will deal with the nerf from now on - .unsaved set to P_NONE means that an unsaved pivot was already taken care of
        pivot.unsaved.did := P_NONE
    }

    return
}

rememberDashZonesNotSaved(aX) {
    global
    ; if the dashzone that will sent to the game is different from the previous, then we record
    if (dashZoneOf(aX) != dashZone.unsaved.zone) {
        dashZone.unsaved.zone := dashZoneOf(aX)
        dashZone.unsaved.timestamp := currentTimeMS
        ; we need to see if the current input actually represents a fresh new dash zone (either from a lone input or
        ; as the FIRST keystroke of a group of simultaneous keystrokes) in order to assign a timestamp to it
        if (currentTimeMS - oldestUnsavedDashZoneTimestamp >= TIMELIMIT_SIMULTANEOUS) {
            oldestUnsavedDashZoneTimestamp := currentTimeMS
            analogHistory[currentIndexA].simultaneousFinish |= FINAL_DASHZONE
        }
    }

    return
}
