#Requires AutoHotkey v1.1

class directionDeadzoneHistoryObject {
    unsaved := new outOfDeadzoneInfo(false, -1000)
    candidates := {}
    saved := new outOfDeadzoneInfo(false, -1000)

    saveHistory() { ; we call this once we mark previous multipress as "ended"
        this.saved := this.unsaved, this.candidates := {}
    }

    storeInfoBeforeMultipressEnds(outputIsOutOfDeadzone) {
        global currentTimeMS

        if (outputIsOutOfDeadzone == this.saved.out) {
            ; if current zone is the same as the last saved zone then its info is still relevant
            this.unsaved := this.saved
        } else {
            if !IsObject(this.candidates[outputIsOutOfDeadzone]) {
                ; if zone is a new zone and is not a candidate, we add a new entry for it
                this.candidates[outputIsOutOfDeadzone] := new outOfDeadzoneInfo(outputIsOutOfDeadzone, currentTimeMS)
            }
            this.unsaved := this.candidates[outputIsOutOfDeadzone]
        }
        return
    }
}

