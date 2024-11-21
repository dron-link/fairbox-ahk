#Requires AutoHotkey v1.1

class limitedOutputsObject {
    historyLength := 12
    limited := {}
    latestMultipressBeginningTimestamp := -1000

    __New() { ; creates output.hist
        this.hist := []
        Loop, % this.historyLength {
            this.hist.Push(new outputHistoryEntry(0, 0, -1000))
        }
    }

    reverseNeutralBNerf() {
        global xComp, global yComp
        nerfedCoords := getReverseNeutralBNerf([this.limited.x, this.limited.y])
        this.limited.x := nerfedCoords[xComp], this.limited.y := nerfedCoords[yComp]
        return
    }

    chooseLockout(pivotWasNerfed, pivotNerfedCoords, uncrouchWasNerfed, uncrouchNerfedCoords) {
        global xComp, global yComp
        ; function for solving conflicts between nerf coordinates
        if pivotWasNerfed {
            this.limited.x := pivotNerfedCoords[xComp]
            this.limited.y := pivotNerfedCoords[yComp]
        } else if uncrouchWasNerfed {
            this.limited.x := uncrouchNerfedCoords[xComp]
            this.limited.y := uncrouchNerfedCoords[yComp]
        }
        return
    }

    horizontalRimFuzz() {
        this.limited.y := getFuzzyHorizontal100(this.limited.x, this.limited.y, this.hist[1].x, this.hist[1].y)
        return
    }
}
