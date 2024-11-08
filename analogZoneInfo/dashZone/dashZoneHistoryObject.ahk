#Requires AutoHotkey v1.1

class dashZoneHistoryObject {
    string := "dashZone"

    historyLength := 6

    unsaved := new dashZoneHistoryEntry(false, -1000, true)
    queue := {}
    saved[] ; as of now, dashZone.saved can't be set, but we can get it this way:
    {
        get {
            return this.hist[1]
        }
    }

    __New() { ; generates dashZone.hist
        this.historyLength := Max(3, this.historyLength) ; at minimum this should be 3
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
                    this.hist[staleIndex].stale := true, staleIndex += 1
                }
                break
            }
        }
        return
    }

    storeInfoBeforeMultipressEnds(aX, aY) {
        global currentTimeMS
        dashZoneOfOutput := getDashZoneOf(aX, aY)
        if (dashZoneOfOutput == this.saved.zone) {
            this.unsaved := this.saved ; we haven't moved onto another zone, so the saved info still applies
        } else {
            if !IsObject(this.queue[dashZoneOfOutput]) { ; if it's not in queue
                ; add a new entry to the queue
                this.queue[dashZoneOfOutput] := new dashZoneHistoryEntry(dashZoneOfOutput, currentTimeMS, false)
            }
            this.unsaved := this.queue[dashZoneOfOutput]
        }
        return
    }
}
