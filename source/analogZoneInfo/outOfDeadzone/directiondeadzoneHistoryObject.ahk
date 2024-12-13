#Requires AutoHotkey v1

class directionDeadzoneHistoryObject {
    unsaved := new outOfDeadzoneInfo(false, -1000)
    candidate := ""
    saved := new outOfDeadzoneInfo(false, -1000)

    saveFilteredHistory() { ; we call this once we mark previous multipress as "ended"
        this.saved := this.unsaved
        this.candidate := "" ; we want IsObject("") = false
    }

    recordDeadzoneOutput(outputIsOutOfDeadzone) {
        global currentTimeMS

        if (outputIsOutOfDeadzone == this.saved.out) {
            ; if current zone is the same as the last saved zone then its info is still relevant
            this.unsaved := this.saved
        } else {
            if !IsObject(this.candidate) {
                ; if zone is a new zone and is not a candidate, we add a new entry for it
                this.candidate := new outOfDeadzoneInfo(outputIsOutOfDeadzone, currentTimeMS)
            }
            this.unsaved := this.candidate
        }
        return
    }
}

