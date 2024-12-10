#Requires AutoHotkey v1

#include %A_WorkingDir%\source\system\gameEngineConstants.ahk

#include %A_WorkingDir%\source\limitOutputs\getFuzzyHorizontal100.ahk

#include %A_WorkingDir%\test\logAppend.ahk

logAppend("testGetFuzzyHorizontal100")
logAppend(A_LineFile "`n")

FUZZ_1_00_PROBABILITY := 100 ; for always changing output y if conditions are met

; if the |x| value is not 80 or more, and y isnt 0, we shouldnt consider fuzzing
testStage := "noFuzzConditions"
logAppend("Running: " testStage)
x := -128
Loop {
    y := -5
    Loop {
        if ((x <= -80 or 80 <= x) and y == 0) {
            ; should be fuzzed, really
        } else {
            if (y != getFuzzyHorizontal100(x, y, 0, 0)) {
                logAppend("Failure report: x " x " y " y " testStage " testStage
                    . ": value Y was changed when it shouldn't")
            }
        }
        y += 1
    } Until y > 5
    x += 1
} Until x > 128
logAppend("End of " testStage ".")

; if output X is the same as history X and outputY is 0 and historyY is zero adjacent,
; result should be historyY
testStage := "alreadyFuzzed"

logAppend("Running: " testStage)
y := 0
x := -128
Loop {
    if (x <= -80 or 80 <= x) {
        Random, randomHistoryY, -2, 2 ; writes -2 -1, 0, 1, or 2
        if (randomHistoryY == -1 or randomHistoryY == 0 or randomHistoryY == 1) { ; properly fuzzed history
            if (randomHistoryY != getFuzzyHorizontal100(x, y, x, randomHistoryY)) {
                logAppend("Failure report: x " x " y " y " randomHistoryY " randomHistoryY
                    . " testStage " testStage
                    . ": result Y wasn't the same as historyY.")
            }
        } else { ; non fuzzed history
            if (randomHistoryY == getFuzzyHorizontal100(x, y, x, randomHistoryY)) {
                logAppend("Failure report: x " x " y " y " randomHistoryY " randomHistoryY
                    . " testStage " testStage
                    . ": historyY, a value that doesn't correspond to a fuzzed cardinal, was used as result.")
            }
        }
    }
    x += 1
} Until x > 128
logAppend("End of " testStage ".")

; if outputX is different to historyX, and |x| >= 80, value should be randomly fuzzed according to
; FUZZ_1_00_PROBABILITY even if history y is adjacent to 0
testStage := "shouldFuzz"
logAppend("Running: " testStage)
x := -128
y := 0
historyY := 0
Loop {
    if (x <= -80 or 80 <= x) {
        ; ensure x =/= historyX
        Random, yesNo, 0, 1
        if yesNo {
            Random, yesNo, 0, 1
            randomHistoryX := x + (yesNo? 1 : -1) ; off by 1
        } else {
            randomHistoryX := -x ; opposite sign
        }

        if (0 == getFuzzyHorizontal100(x, y, randomHistoryX, historyY)) {
            logAppend("Failure report: x " x " y " y " randomHistoryY " randomHistoryY " testStage " testStage
                . ": result wasn't fuzzed when it should be." )
        }
    }
    x += 1
} Until x > 128
logAppend("End of " testStage ".")

; if outputX is different to historyX, and |x| >= 80, value should be randomly fuzzed according to
; FUZZ_1_00_PROBABILITY.
testStage := "fuzzDisabled"
logAppend("Running: " testStage)
FUZZ_1_00_PROBABILITY := 0 ; 0% chance of fuzziness
x := -128
y := 0
historyY := 64 ; arbitrary number away from 0
Loop {
    if (x <= -80 or 80 <= x) {
        ; ensure x =/= historyX to make the program try fuzzing
        Random, yesNo, 0, 1
        if yesNo {
            Random, yesNo, 0, 1
            randomHistoryX := x + (yesNo? 1 : -1) ; off by 1
        } else {
            randomHistoryX := -x ; opposite sign, note that x is =/= 0
        }

        if (y != getFuzzyHorizontal100(x, y, randomHistoryX, historyY)) {
            logAppend("Failure report: x " x " y " y " randomHistoryY " randomHistoryY " testStage " testStage
                . ": result was fuzzed even when fuzz probability is set to 0" )
        }
    }
    x += 1
} Until x > 128
logAppend("End of " testStage ".")

logAppend("testGetFuzzyHorizontal100 finish.`n")