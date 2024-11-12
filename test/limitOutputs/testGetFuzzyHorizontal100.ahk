#Requires AutoHotkey v1.1

/*  ; This is how getFuzzyHorizontal100 should look like if you're going to test it.
    ; As written, this passed the test I designed.

getFuzzyHorizontal100(outputX, outputY, historyX, historyY) {
    global ANALOG_STICK_MAX, global ANALOG_STEP, global FUZZ_1_00_PROBABILITY

    if (outputY == 0 and Abs(outputX) >= ANALOG_STICK_MAX) {
        testGFH100NoFuzzConditions(outputX, outputY)
        if (Abs(historyY) <= ANALOG_STEP and outputX == historyX) {
            testGFH100ShouldFuzz(outputX, outputY, historyX, historyY)
            return historyY
        } else {
            testGFH100AlreadyFuzzed(outputX, outputY, historyX, historyY)
            Random, ran100, 0, 99 ; spans 100%
            if (ran100 < FUZZ_1_00_PROBABILITY) {
                Random, yesNo, 0, 1
                return yesNo ? ANALOG_STEP : -ANALOG_STEP
            } else {
                return 0
            }
        }
    } else {
        testGFH100AlreadyFuzzed(outputX, outputY, historyX, historyY)
        testGFH100ShouldFuzz(outputX, outputY, historyX, historyY)
        return outputY
    }
}

*/

testGetFuzzyHorizontal100() {
    global testStage, global ANALOG_STICK_MAX, global ANALOG_STICK_MIN
    OutputDebug, % "testGetFuzzyHorizontal100()`n"
    logAppend("testGetFuzzyHorizontal100()")
    ; if the |x| value is not 80 or more, and y isnt 0, we shouldnt consider fuzzing
    testStage := "noFuzzConditions"
    logAppend("Running: " testStage)
    x := -128
    Loop { 
        y := -128
        Loop, 300 {
            if ((x <= -80 or 80 <= x) and y == 0) {
                ; should be fuzzed, really
            } else {
                if (y != getFuzzyHorizontal100(x, y, 0, 0)) {
                    logAppend("Failure report: x " x " y " y 
                    . ": value Y was changed when it shouldn't")
                }
            }
            y += 1
        } Until y > 128
        x += 1
    } Until x > 128
    logAppend("End of " testStage ".")

    ; if output X is the same as history X and outputY is 0 and historyY is zero adjacent,
    ; result should be historyY
    testStage := "alreadyFuzzed"

    logAppend("Running: " testStage)
    x := -128
    y := 0
    Loop {
        if (x <= -80 or 80 <= x) {
            Random, randomHistoryY, -1, 1
            if (randomHistoryY != getFuzzyHorizontal100(x, y, x, randomHistoryY)) {
                logAppend("Failure report: x " x " y " y " randomHistoryY " randomHistoryY
                . ": result Y wasn't the same as historyY.")
            }
        }
        x += 1
    } Until x > 128
    logAppend("End of " testStage ".")

    ; if outputX is different to historyX, and |x| >= 80, value should be fuzzed,
    ; even if history y is 0adjacent
    testStage := "shouldFuzz"
    logAppend("Running: " testStage)
    x := -128
    y := 0
    Loop {
        if (x <= -80 or 80 <= x) {
            Random, randomHistoryY, -1, 1
            Random, yesNo, 0, 1
            randomHistoryX := x + (yesNo? 1 : -1) ; ensure x =/= historyX
            getFuzzyHorizontal100(x, y, randomHistoryX, randomHistoryY)            
        }
        x += 1
    } Until x > 128
    logAppend("End of " testStage ".")
    
    logAppend("Test finished.`n`n")
}

testGFH100NoFuzzConditions(x, y) {
    global testStage
    if (testStage = "noFuzzConditions") {
        logAppend("Failure report: x " x " y " y 
        . ": candidates for fuzzing, when they shouldn't be")
    }
}

testGFH100AlreadyFuzzed(x, y, histX, histY) {
    global testStage
    if (testStage = "alreadyFuzzed") {
        logAppend("Failure report: x " x " y " y " histX " histX " histY " histY
        . ": were either fuzzed or not even candidates, and none of this should happen.")
    }
}

testGFH100ShouldFuzz(x, y, histX, histY) {
    global testStage
    if (testStage = "shouldFuzz") {
        logAppend("Failure report: x " x " y " y " histX " histX " histY " histY ":`n"
        . "-> Output was copied from history or input was not even a candidate.")
    }
}

