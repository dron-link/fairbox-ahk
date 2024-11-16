#Requires AutoHotkey v1.1

class directionDeadzoneHistoryObject {
    unsaved := new outOfDeadzoneInfo(false, -1000)
    queue := {}
    saved := new outOfDeadzoneInfo(false, -1000)

    saveHistory() { ; we call this once we mark previous multipress as "ended"
        this.saved := this.unsaved, this.queue := {}
    }

    storeInfoBeforeMultipressEnds(aX_or_aY) {
        global currentTimeMS
        /*  depending on the class that extends this class, the following line calls:
            getIsOutOfDeadzone_up(aY) or
            getIsOutOfDeadzone_down(aY)
        */
        deadzoneStatus := this.getIsOutOfDeadzone_Func.Call(aX_or_aY)
        if (deadzoneStatus == this.saved.out) {
            ; if current zone is the same as the last saved zone then its info is still relevant
            this.unsaved := this.saved
        } else {
            if !IsObject(this.queue[deadzoneStatus]) {
                ; if zone is a new zone and is not in the queue, we add a new entry for it
                this.queue[deadzoneStatus] := new outOfDeadzoneInfo(deadzoneStatus, currentTimeMS)
            }
            this.unsaved := this.queue[deadzoneStatus]
        }
        return
    }
}

class upDeadzoneHistoryObject extends directionDeadzoneHistoryObject {
    getIsOutOfDeadzone_Func := Func("getIsOutOfDeadzone_up")
}

class downDeadzoneHistoryObject extends directionDeadzoneHistoryObject {
    getIsOutOfDeadzone_Func := Func("getIsOutOfDeadzone_down")
}

