#Requires AutoHotkey v1

class dashZoneHistoryObject {
    historyLength := 6

    unsaved := new dashZoneHistoryEntry(false, -1000, false)
    candidates := {} ; associative array
    saved[] ; as of now, dashZone.saved can't be set, but we can get it this way:
    {
        get {
            return this.hist[1]
        }
    }

    pivotLockoutEntry := new dashZoneHistoryEntry(false, -1000, false)
    
    __New() { ; generates dashZone.hist
        this.historyLength := Max(3, this.historyLength) ; at minimum this should be 3
        this.hist := []
        Loop, % this.historyLength {
            this.hist.Push(new dashZoneHistoryEntry(false, -1000, false))
        }
    }

    saveFilteredHistory() { ; called every time a simultaneous multiple keypress event has ended
        ; we compare addresses here to avoid inserting the same old object consecutively
        if (this.unsaved != this.saved) { 
            this.hist.Pop(), this.hist.InsertAt(1, this.unsaved)
        }

        this.candidates := {}
        if this.saved.pivot {
            this.pivotLockoutEntry := this.saved
        }
        return
    }

    recordDashOutput(dashZoneOfOutput) {
        global currentTimeMS
        
        if (dashZoneOfOutput == this.saved.zone) {
            this.unsaved := this.saved ; we haven't moved onto another zone, so the saved info still applies
        } else {
            if !IsObject(this.candidates[dashZoneOfOutput]) { ; if it's not in the candidates array
                ; add a new entry to candidates. stores whether this program outputted a pivot or not
                this.candidates[dashZoneOfOutput] := new dashZoneHistoryEntry(dashZoneOfOutput, currentTimeMS
                , getPivotDid(this.hist, dashZoneOfOutput, currentTimeMS))
            }

            this.unsaved := this.candidates[dashZoneOfOutput]
        }
        return
    }
}
