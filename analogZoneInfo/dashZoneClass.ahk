#Requires AutoHotkey v1.1

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