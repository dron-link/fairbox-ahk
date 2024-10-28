#Requires AutoHotkey v1.1

; analog history
class outputHistoryEntry {
    __New(x, y, timestamp) {
        ;         1            2                    3
        this.x := x, this.y := y, this.timestamp := timestamp
        this.multipress := {began : false, ended : false}
    }
}

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

    horizontalRimFuzz() {
        this.limited.y := getFuzzyHorizontal100(this.limited.x, this.limited.y, this.hist[1].x, this.hist[1].y)
        return
    }
}

getReverseNeutralBNerf(ByRef aX, ByRef aY) {
    global ANALOG_DEAD_MAX, global ANALOG_STICK_MIN, global ANALOG_STICK_MAX, 
    global ANALOG_SPECIAL_LEFT, global ANALOG_SPECIAL_RIGHT, global buttonB

    if (buttonB and Abs(aX) > ANALOG_DEAD_MAX and Abs(aY) <= ANALOG_DEAD_MAX) { ; out of x deadzone and in y deadzone
        if (aX < 0 and aX > ANALOG_SPECIAL_LEFT) { ; inside leftward neutral-B range
            return [ANALOG_STICK_MIN, 0]
        } else if (aX > 0 and aX < ANALOG_SPECIAL_RIGHT) { ; inside rightward neutral-B range
            return [ANALOG_STICK_MAX, 0]
        }
    }
    return [aX, aY]
}

getFuzzyHorizontal100(outputX, outputY, historyX, historyY) {
    /*  if you input [+/- 80, 0], that value may be passed to the game
        as [+/- 80, +/- 1] for as long as you hold the stick in the same place
    */
    global ANALOG_STICK_MAX, global ANALOG_STEP, global FUZZ_1_00_PROBABILITY

    if(Abs(outputY) <= ANALOG_STEP and Abs(outputX) == ANALOG_STICK_MAX) {
        if (Abs(historyY) <= ANALOG_STEP and outputX == historyX) {
            return historyY
        } else {
            Random, ran100, 0, 99 ; spans 100%
            if (ran100 < FUZZ_1_00_PROBABILITY) {
                result := Mod(ran100, 2) ? ANALOG_STEP : (-ANALOG_STEP)
                return result
            } else {
                return 0
            }
        }
    } else {
        return outputY
    }
}
