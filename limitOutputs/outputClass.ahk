#Requires AutoHotkey v1.1

class outputBase {
    static historyLength := 15
    limited := {}
    latestMultipressBeginningTimestamp := -1000

    __New() {
        this.hist := []
        Loop, % this.historyLength {
            this.hist.Push(new outputHistoryEntry(0, 0, -1000))
        }
    }

    reverseNeutralBNerf() {
        global xComp, global yComp
        nerfedCoords := getReverseNeutralBNerf(this.limited.x, this.limited.y)
        this.limited.x := nerfedCoords[xComp], this.limited.y := nerfedCoords[yComp]
        return
    }

    chooseLockout(pivot, uncrouch) {
        global xComp, global yComp
        if pivot.wasNerfed { ;
            this.limited.x := pivot.nerfedCoords[xComp]
            this.limited.y := pivot.nerfedCoords[yComp]
        } else if uncrouch.wasNerfed {
            this.limited.x := uncrouch.nerfedCoords[xComp]
            this.limited.y := uncrouch.nerfedCoords[yComp]
        }
        return
    }

    horizontalRimFuzz() {
        this.limited.y := getFuzzyHorizontal100(this.limited.x, this.limited.y, this.hist[1].x, this.hist[1].y)
        return
    }
}