#Requires AutoHotkey v1.1

class outputHistoryObject {
    historyLength := 7
    limited := {}
    latestMultipressBeginningTimestamp := -1000

    __New() { ; creates output.hist
        this.hist := []
        Loop, % this.historyLength {
            this.hist.Push(new outputHistoryEntry(0, 0, -1000, false))
        }
    }
}
