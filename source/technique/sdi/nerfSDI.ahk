#Requires AutoHotkey v1

; // for sdi nerfs, we want to record only movement between sdi zones, ignoring movement within zones
class sdiZoneHistoryEntry {
    timestamp := -1000, stale := true, zone := 0, popcount := 0
}
sdiZoneHist := []
Loop, % SDI_HISTORY_LENGTH {
    sdiZoneHist.Push(new sdiZoneHistoryEntry)
}
sdiSimultZone := 0
sdiSimultTimestamp := -1000

countPopulation(bitsIn) { ; //not a general purpose popcount, this is specifically for sdi zones
    result := 0
    Loop,4 {
        result += (bitsIn>>(A_Index-1)) & 1
    }
    return result
}

sdiZone(aX, aY) {
    global

    result := 0
    if (Min(Abs(aX), Abs(aY)) <= ANALOG_DEAD_MAX) { ; is x or y in the deadzone
        if (aX >= ANALOG_SDI_RIGHT) {
            result |= ZONE_R
        } else if (aX <= ANALOG_SDI_LEFT) {
            result |= ZONE_L
        } else if (aY >= ANALOG_SDI_UP) {
            result |= ZONE_U
        } else if (aY <= ANALOG_SDI_DOWN) {
            result |= ZONE_D
        }
    } else if (aX**2 + aY**2 >= MELEE_SDI_RAD) { ; is the distance far enough for diagonal sdi
        if (aX > 0) {
            result |= ZONE_R
        } else { ; if aX < 0
            result |= ZONE_L
        }
        if (aY > 0) {
            result |= ZONE_U
        } else { ; if aY < 0
            result |= ZONE_D
        }
    }

    return result
}

isBurstSDI1Button(outputIn) {
    global

    output := outputIn

    ; //detect repeated center-cardinal sequences, or repeated cardinal-diagonal sequences
    ; // if we're changing zones back and forth
    if (sdiZoneHist[1].zone != sdiZoneHist[2].zone
        and sdiZoneHist[1].zone == sdiZoneHist[3].zone
        and sdiZoneHist[2].zone == sdiZoneHist[4].zone) {
        ;//check the time duration
        timePressToPress := sdiZoneHist[1].timestamp - sdiZoneHist[3].timestamp
        ;//We want to nerf it if there is more than one press every TIMELIMIT_BURSTSDI ms,
        ;//but not if the previous release duration is less than 1 frame
        if (sdiZoneHist[4].stale == false and timePressToPress < TIMELIMIT_BURSTSDI and timePressToPress > TIMELIMIT_DEBOUNCE) {
            if (sdiZoneHist[1].zone == 0 or sdiZoneHist[2].zone == 0) {
                output |= BITS_SDI_TAP_CARD ;//if one of the pairs of zones is zero, it's tapping a cardinal (or tapping a diagonal modifier)
            } else if (sdiZoneHist[1].popcount + sdiZoneHist[2].popcount == POP_DIAG + POP_CARD
                and (sdiZoneHist[1].zone & sdiZoneHist[2].zone)) {
                output |= BITS_SDI_TAP_DIAG ;//one pair is cardinal and the other is adjacent diagonal
            }
        }
    }

    return output
}

isBurstSDICrDg(outputIn) {
    global
    output := outputIn

    ;//if the last 5 inputs are in the origin, one cardinal, and one diagonal
    ;//and that there was a recent return to center
    ;//at least one of each zone, and at least two diagonals
    origCount := 0
    cardCount := 0
    diagCount := 0
    diagZone := (1<<8) - 1 ; 0b1111'1111
    Loop,5 {
        popcnt := sdiZoneHist[A_Index].popcount
        if (popcnt == POP_CENTER) {
            origCount += 1
        } else if (popcnt == POP_CARD) {
            cardCount += 1
        } else { ; if popcnt == POP_DIAG
            diagCount += 1
            diagZone &= sdiZoneHist[A_Index].zone ;//if two of these diagonals don't match, it'll have zero or one bits set
            ; if they match, the pop will be two bits
        }
    }

    ;//to limit scope of these vars
    ;//check the bit count of diagonal matching
    diagMatch := countPopulation(diagZone) == 2
    ;//check whether the input was fast enough
    shortTime := (sdiZoneHist[1].timestamp - sdiZoneHist[5].timestamp < TIMELIMIT_BURSTSDI
        and sdiZoneHist[1].timestamp - sdiZoneHist[2].timestamp > TIMELIMIT_SIMULTANEOUS
        and sdiZoneHist[5].stale == false)
    ;// if only the same diagonal was pressed
    ;//              if the origin, cardinal, and two diagonals were all entered
    ;//                                                            within the time limit
    if(diagMatch and origCount and cardCount and diagCount > 1 and shortTime) {
        output |= BITS_SDI_TAP_CRDG
    }

    return output
}

isBurstSDIQuarterCircle(outputIn) {
    global
    output := outputIn

    ;//3 input sdi
    ;//center-cardinal-diagonal-diagonal
    ;//center-cardinal-diagonal-same cardinal-diagonal
    ;//all directions except center must be the same
    cardZone := (1<<8) - 1 ; 0b1111'1111
    diagZone := (1<<8) - 1
    origCount = 0;
    cardCount = 0;
    diagCount = 0;
    Loop,5 {
        popcnt := sdiZoneHist[A_Index].popcount
        if (popcnt == POP_CENTER) {
            origCount += 1
            break ;//stop counting once there's an origin
        } else if (popcnt == POP_CARD) {
            cardCount += 1
            cardZone &= sdiZoneHist[A_Index].zone ;//if there are two different cardinals then it'll have zero bits set
        } else { ; if popcnt == POP_DIAG
            diagCount += 1
            diagZone &= sdiZoneHist[A_Index].zone ; if these are adjacent, it'll have one bit set
        }
    }

    ;//to limit scope of these vars
    ;//check the bit count of diagonal matching
    adjacentDiag := countPopulation(diagZone) == 1 and (cardZone & diagZone)
    shortTime := sdiZoneHist[1].timestamp - sdiZoneHist[4].timestamp < TIMELIMIT_BURSTSDI
        and not (sdiZoneHist[3].stale or (sdiZoneHist[4].stale and sdiZoneHist[4].zone != 0))
    ;//if it hit two different diagonals
    ;//                  hit origin, at least one cardinal, and two diagonals
    ;//                                                                within the time limit
    if (adjacentDiag and origCount and cardCount and diagCount > 1 and shortTime) {
        output |= BITS_SDI_QUARTERC
    }

    return output
}

detectBurstSDI(aX, aY) {
    global

    output := 0
    sdiZoneHist[1].zone := sdiZone(aX, aY)
    sdiZoneHist[1].popcount := countPopulation(sdiZoneHist[1].zone)
    sdiZoneHist[1].timestamp := currentTimeMS
    sdiZoneHist[1].stale := false

    output := isBurstSDI1Button(output)
    if (sdiZoneHist[1].zone != sdiZoneHist[2].zone) {
        output := isBurstSDICrDg(output)
    }
    output := isBurstSDIQuarterCircle(output)

    ;//return the last cardinal in the zone list before the last diagonal, useful for SDI diagonal nerfs.
    Loop, % SDI_HISTORY_LENGTH {
        if (sdiZoneHist[A_Index].popcount == POP_DIAG) {
            i := A_Index + 1
            while (i <= SDI_HISTORY_LENGTH) {
                if (sdiZoneHist[i].popcount == POP_CARD) {
                    output |= sdiZoneHist[i].zone
                    break
                }
                i += 1
            }
            break
        }
    }

    return output
}

updateSDIZoneHistory() {
    global

    ; sdiZoneHist update
    ; we reserve sdiZoneHist[1, zh] for sdi detector

    if (sdiSimultZone != sdiZoneHist.zone) {
        newSdiZoneHistoryEntry := new sdiZoneHistoryEntry
        newSdiZoneHistoryEntry.timestamp := sdiSimultTimestamp
        newSdiZoneHistoryEntry.stale := false
        newSdiZoneHistoryEntry.zone := sdiSimultZone
        newSdiZoneHistoryEntry.popcount := countPopulation(sdiSimultZone)

        sdiZoneHist.Pop(), sdiZoneHist.InsertAt(2, newSdiZoneHistoryEntry)
    }
    return
}

makeSDIZoneStale() {
    global

    Loop, % SDI_HISTORY_LENGTH { ; check if a sdi zone entry (and subsequent ones) are stale, and flag them
        if (currentTimeMS - sdiZoneHist[A_Index].timestamp > TIMESTALE_SDI_INPUTSEQUENCE) {
            staleIndex := A_Index ; found stale entry
            while(staleIndex <= SDI_HISTORY_LENGTH) {
                sdiZoneHist[staleIndex].stale := true
                staleIndex += 1
            }
            break
        }
    }

    return
}

saveSDIHistory() {
    global

    updateSDIZoneHistory()
    makeSDIZoneStale()

    return
}

rememberSDIZonesNotSaved(aX, aY) {
    global

    /*

    if (currentTimeMS - sdiSimultTimestamp >= TIMELIMIT_SIMULTANEOUS and sdiZone(aX, aY) != sdiSimultZone) {
      sdiSimultZone := sdiZone(aX, aY)
      sdiSimultTimestamp := currentTimeMS
      analogHistory[currentIndexA].simultaneousFinish |= FINAL_SDIZONE
    }
    */

    return
}
