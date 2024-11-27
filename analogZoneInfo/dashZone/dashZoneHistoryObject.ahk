#Requires AutoHotkey v1.1

class dashZoneHistoryObject {
    historyLength := 6

    unsaved := new dashZoneHistoryEntry(false, -1000)
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
            this.hist.Push(new dashZoneHistoryEntry(false, -1000))
        }
    }

    saveHistory() {
        ; we compare addresses to avoid inserting the same old object consecutively
        if (this.unsaved != this.saved) { 
            this.hist.Pop(), this.hist.InsertAt(1, this.unsaved)
        }
        this.queue := {}
        return
    }

    storeInfoBeforeMultipressEnds(dashZoneOfOutput) {
        global currentTimeMS
        
        if (dashZoneOfOutput == this.saved.zone) {
            this.unsaved := this.saved ; we haven't moved onto another zone, so the saved info still applies
        } else {
            if !IsObject(this.queue[dashZoneOfOutput]) { ; if it's not in queue
                ; add a new entry to the queue
                this.queue[dashZoneOfOutput] := new dashZoneHistoryEntry(dashZoneOfOutput, currentTimeMS)
            }
            this.unsaved := this.queue[dashZoneOfOutput]
        }
        return
    }
}
